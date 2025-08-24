import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_model.dart';

class LoginController extends GetxController {
  var loginAttempts = 0.obs;
  var showError = false.obs;
  var isLoading = false.obs;
  var isFirstLogin = false.obs;

  String? lastErrorMessage;
  String? userRole;
  String? token; //  إضافة متغير لحفظ التوكن
  String? employeeId; //  ممكن تحتاجه بشكل متكرر
  String? userId; //  ممكن تحتاجه بشكل متكرر

  Future<bool> login(LoginModel model) async {
    isLoading.value = true;

    final url = Uri.parse('http://192.168.1.213/api/Auth/login');

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(model.toJson()),
      );
      print('API response: ${res.body}');

      isLoading.value = false;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        token = data['token']; //  خزّن التوكن
        isFirstLogin.value = data['isFirstLogin'] ?? false;

        String? role;
        bool isEmployee = false;

        if (token != null && token!.isNotEmpty) {
          final decodedToken = JwtDecoder.decode(token!);

          // أدوار
          final roleData =
              decodedToken['role'] ??
              decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
              decodedToken['roles'];

          if (roleData is List) {
            isEmployee = roleData
                .map((e) => e.toString().toLowerCase())
                .contains('employee');
            role =
                isEmployee
                    ? 'Employee'
                    : (roleData.isNotEmpty ? roleData.first.toString() : null);
          } else if (roleData is String) {
            isEmployee = roleData.toLowerCase() == 'employee';
            role = roleData;
          }

          employeeId =
              decodedToken['CompanyId'] ??
              decodedToken['employeeCode'] ??
              decodedToken['userName'] ??
              data['CompanyId'] ??
              data['employeeCode'] ??
              data['userName'] ??
              model.userName;

          userId =
              decodedToken['userId'] ??
              decodedToken['nameid'] ??
              decodedToken['sub'] ??
              data['userId'];
        }

        userRole = role;
        print('User role: $userRole');
        print('employeeId: $employeeId');
        print('userId: $userId');

        if (!isEmployee) {
          lastErrorMessage = "هذا التطبيق مخصص فقط للموظفين.";
          Get.snackbar("خطأ", lastErrorMessage!);
          return false;
        }

        // التخزين في SharedPreferences (احتياطي)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token!);
        await prefs.setString('employee_id', employeeId ?? model.userName);
        if (userId != null && userId!.isNotEmpty) {
          await prefs.setString('user_id', userId!);
        }

        loginAttempts.value = 0;
        showError.value = false;
        lastErrorMessage = null;
        return true;
      } else if (res.statusCode == 401 || res.statusCode == 400) {
        loginAttempts.value++;
        showError.value = true;
        lastErrorMessage = "Your password is incorrect.";
        if (loginAttempts.value >= 3) {
          lastErrorMessage =
              "You've entered the wrong password 3 times.\nA verification link has been sent to your email to reset your password.";
        }
        Get.snackbar("Error", lastErrorMessage ?? "");
        return false;
      } else {
        loginAttempts.value++;
        showError.value = true;
        lastErrorMessage = "Something went wrong, try again!";
        Get.snackbar("Error", lastErrorMessage ?? "");
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      lastErrorMessage = "Network error: $e";
      Get.snackbar("Error", lastErrorMessage ?? "");
      print("LOGIN EXCEPTION: $e");
      return false;
    }
  }

  void resetLoginAttempts() {
    loginAttempts.value = 0;
    showError.value = false;
    lastErrorMessage = null;
  }
}

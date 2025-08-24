import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;

  Future<bool> changePassword(
    String newPassword,
    String confirmPassword,
  ) async {
    isLoading.value = true;
    errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('http://192.168.1.213/api/Auth/change-password');
    final res = await http.put(
      url,

      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      }),
    );

    isLoading.value = false;

    if (res.statusCode == 200) {
      return true;
    } else {
      errorMessage =
          jsonDecode(res.body)['message'] ?? "Failed to change password!";
      return false;
    }
  }
}

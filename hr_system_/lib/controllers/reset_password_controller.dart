import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ResetPasswordController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;

  Future<bool> resetPassword(
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    isLoading.value = true;
    final url = Uri.parse("http://192.168.1.128:5000/api/Auth/reset-password");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "newPassword": newPassword,
          "confirmNewPassword": confirmPassword,
        }),
      );
      isLoading.value = false;
      if (res.statusCode == 200) {
        return true; // بعدها يعمل Login وبهيك ناخذ ونخزّن userId هناك
      } else {
        errorMessage = "Failed to reset password!";
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage = "Network error: $e";
      return false;
    }
  }
}

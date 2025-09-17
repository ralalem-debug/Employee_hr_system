import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../app_config.dart';

class ResetPasswordController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;

  static const _timeout = Duration(seconds: 15);

  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl); // مثال: http://x.x.x.x/api
    final basePath =
        b.path.endsWith('/')
            ? b.path.substring(0, b.path.length - 1)
            : b.path; // "/api"
    final addPath =
        path.startsWith('/') ? path.substring(1) : path; // "Auth/..."
    return b.replace(path: '$basePath/$addPath'); // "/api/Auth/..."
  }

  Future<bool> resetPassword(
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    isLoading.value = true;
    errorMessage = null;

    // ✅ تحقق بسيط قبل الطلب
    if (token.trim().isEmpty) {
      errorMessage = "Invalid or missing reset token.";
      isLoading.value = false;
      return false;
    }
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      errorMessage = "Please fill in all fields.";
      isLoading.value = false;
      return false;
    }
    if (newPassword != confirmPassword) {
      errorMessage = "Passwords do not match.";
      isLoading.value = false;
      return false;
    }
    if (newPassword.length < 6) {
      errorMessage = "Password must be at least 6 characters.";
      isLoading.value = false;
      return false;
    }

    try {
      final res = await http
          .post(
            _u('/Auth/reset-password'),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              "token": token.trim(),
              "newPassword": newPassword,
              "confirmNewPassword": confirmPassword,
            }),
          )
          .timeout(_timeout);

      if (res.statusCode == 200 || res.statusCode == 204) {
        isLoading.value = false;
        return true; // بعدها بإمكانك توجه المستخدم لصفحة تسجيل الدخول
      } else {
        // جرّب نستخلص رسالة مفيدة من الرد
        try {
          final body = jsonDecode(res.body);
          if (body is Map && body['message'] is String) {
            errorMessage = body['message'];
          } else if (body is Map && body['error'] is String) {
            errorMessage = body['error'];
          } else if (body is Map &&
              body['errors'] is List &&
              body['errors'].isNotEmpty) {
            errorMessage = (body['errors'] as List).join('\n');
          } else {
            errorMessage = "Failed to reset password! (${res.statusCode})";
          }
        } catch (_) {
          errorMessage = "Failed to reset password! (${res.statusCode})";
        }
        isLoading.value = false;
        return false;
      }
    } on TimeoutException {
      errorMessage = "Connection timeout. Please try again.";
      isLoading.value = false;
      return false;
    } catch (e) {
      errorMessage = "Network error: $e";
      isLoading.value = false;
      return false;
    }
  }
}

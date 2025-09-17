import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../app_config.dart';

class ChangePasswordController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;

  // ✅ Secure storage instance
  final storage = const FlutterSecureStorage();
  static const _timeout = Duration(seconds: 15);

  Future<String?> _getToken() => storage.read(key: 'auth_token');

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

  Future<bool> changePassword(
    String newPassword,
    String confirmPassword,
  ) async {
    isLoading.value = true;
    errorMessage = null;

    try {
      // تحقّق بسيط قبل الطلب
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
      // (اختياري) حد أدنى للطول
      if (newPassword.length < 6) {
        errorMessage = "Password must be at least 6 characters.";
        isLoading.value = false;
        return false;
      }

      final token = await _getToken();
      if (token == null || token.isEmpty) {
        errorMessage = "Missing authentication token!";
        isLoading.value = false;
        return false;
      }

      final res = await http
          .put(
            _u('/Auth/change-password'),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({
              "newPassword": newPassword,
              "confirmPassword": confirmPassword,
            }),
          )
          .timeout(_timeout);

      isLoading.value = false;

      if (res.statusCode == 200 || res.statusCode == 204) {
        return true;
      } else if (res.statusCode == 401) {
        errorMessage = "Unauthorized. Please login again.";
        return false;
      } else {
        // حاول نقرأ رسالة واضحة من جسم الرد (message / error / errors[])
        try {
          final body = jsonDecode(res.body);
          if (body is Map) {
            if (body['message'] is String) {
              errorMessage = body['message'];
            } else if (body['error'] is String) {
              errorMessage = body['error'];
            } else if (body['errors'] is List && body['errors'].isNotEmpty) {
              errorMessage = body['errors'].join('\n');
            } else {
              errorMessage = "Failed to change password! (${res.statusCode})";
            }
          } else {
            errorMessage = "Failed to change password! (${res.statusCode})";
          }
        } catch (_) {
          errorMessage = "Failed to change password! (${res.statusCode})";
        }
        return false;
      }
    } on TimeoutException {
      isLoading.value = false;
      errorMessage = "Connection timeout. Please try again.";
      return false;
    } catch (e) {
      isLoading.value = false;
      errorMessage = "Error: $e";
      return false;
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hr_system_/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginResult {
  final bool success;
  final String message;
  final bool isFirstLogin;
  final String? token;
  final String? role;

  LoginResult({
    required this.success,
    required this.message,
    this.isFirstLogin = false,
    this.token,
    this.role,
  });
}

class LoginController {
  final emailOrUserController = TextEditingController();
  final passwordController = TextEditingController();

  final _secureStorage = const FlutterSecureStorage();

  void dispose() {
    emailOrUserController.dispose();
    passwordController.dispose();
  }

  Future<LoginResult> login() async {
    final input = emailOrUserController.text.trim(); // Username أو Email
    final password = passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      return LoginResult(success: false, message: "Please fill in all fields");
    }

    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/Auth/login');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'userName': input, 'password': password}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          return LoginResult(
            success: false,
            message: "Invalid server response",
          );
        }

        final token = data['token'] as String?;
        final isFirstLogin = (data['isFirstLogin'] as bool?) ?? false;

        if (token == null || token.isEmpty) {
          return LoginResult(
            success: false,
            message: "No token returned from server",
          );
        }

        // استخرج الدور من الـ JWT مع دعم أكثر من شكل
        String? role;
        try {
          final decodedToken = JwtDecoder.decode(token);
          dynamic rawRole =
              decodedToken['role'] ??
              decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
              decodedToken['roles'];
          if (rawRole is List && rawRole.isNotEmpty) {
            role = rawRole.first.toString();
          } else if (rawRole is String) {
            role = rawRole;
          }
        } catch (_) {
          // تجاهل لو فشل فك التشفير
        }

        // ✅ تخزين التوكن
        await _secureStorage.write(key: "auth_token", value: token);

        return LoginResult(
          success: true,
          message: "Login successful",
          token: token,
          isFirstLogin: isFirstLogin,
          role: role,
        );
      } else {
        // حاول نقرأ رسالة الخطأ من السيرفر لو موجودة
        String serverMsg = response.body;
        try {
          final m = jsonDecode(response.body);
          if (m is Map && m['message'] is String) serverMsg = m['message'];
          if (m is Map && m['error'] is String) serverMsg = m['error'];
        } catch (_) {}
        return LoginResult(
          success: false,
          message: "Error ${response.statusCode}: $serverMsg",
        );
      }
    } on Exception {
      return LoginResult(
        success: false,
        message: "Could not connect to the server",
      );
    }
  }

  /// ✅ استرجاع التوكن
  Future<String?> getToken() async {
    return _secureStorage.read(key: "auth_token");
  }

  /// ✅ حذف التوكن (تسجيل خروج)
  Future<void> logout() async {
    await _secureStorage.delete(key: "auth_token");
  }
}

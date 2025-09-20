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

  // helper صغير لاستخراج أول claim غير فاضي
  String? _claim(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  Future<LoginResult> login() async {
    final input = emailOrUserController.text.trim();
    final password = passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      return LoginResult(success: false, message: "Please fill in all fields");
    }

    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/Auth/login');
      print("🔗 Login URL: ${AppConfig.baseUrl}/Auth/login");

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

        // نفك التوكن ونستخرج role + userId + employeeId
        String? role;
        String? userId;
        String? employeeId;
        String? displayName;

        try {
          final t = JwtDecoder.decode(token);

          // role (يدعم أكثر من شكل)
          final rawRole =
              t['role'] ??
              t['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
              t['roles'];
          if (rawRole is List && rawRole.isNotEmpty) {
            role = rawRole.first.toString();
          } else if (rawRole is String) {
            role = rawRole;
          }

          // userId من أشهر المفاتيح المعروفة
          userId = _claim(t, [
            'sub',
            'userId',
            'uid',
            'nameid',
            'nameId',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
            'http://schemas.microsoft.com/ws/2008/06/identity/claims/nameidentifier',
          ]);

          // employeeId لو السيرفر بيحط claim له
          employeeId = _claim(t, ['employeeId', 'empId', 'employee_id']);

          // اسم للعرض (اختياري)
          displayName = _claim(t, [
            'name',
            'unique_name',
            'preferred_username',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name',
          ]);
        } catch (_) {
          // تجاهل أخطاء فك التوكن
        }

        // خزّن التوكن دائماً
        await _secureStorage.write(key: "auth_token", value: token);

        // خزّن user_id لاستخدامه مع office-status
        if (userId != null) {
          await _secureStorage.write(key: "user_id", value: userId);
          print("✅ saved user_id: $userId");
        }

        // خزّن employee_id إن وُجد (مفيد لبعض الـ APIs)
        if (employeeId != null) {
          await _secureStorage.write(key: "employee_id", value: employeeId);
          print("✅ saved employee_id: $employeeId");
        }

        if (displayName != null) {
          await _secureStorage.write(key: "display_name", value: displayName);
        }
        if (role != null) {
          await _secureStorage.write(key: "role", value: role);
        }

        return LoginResult(
          success: true,
          message: "Login successful",
          token: token,
          isFirstLogin: isFirstLogin,
          role: role,
        );
      } else {
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

  Future<String?> getToken() => _secureStorage.read(key: "auth_token");
  Future<void> logout() async {
    await _secureStorage.delete(key: "auth_token");
    await _secureStorage.delete(key: "user_id");
    await _secureStorage.delete(key: "employee_id");
    await _secureStorage.delete(key: "display_name");
    await _secureStorage.delete(key: "role");
  }
}

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
  final List<String>? roles;

  LoginResult({
    required this.success,
    required this.message,
    this.isFirstLogin = false,
    this.token,
    this.roles,
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

  /// 🔑 helper function to pick a claim
  String? _claim(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  /// 🔹 Login API
  Future<LoginResult> login() async {
    final input = emailOrUserController.text.trim();
    final password = passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      return LoginResult(success: false, message: "Please fill in all fields");
    }

    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/Auth/login');
      print("🔗 Login URL: $uri");

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userName': input, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String?;
        final isFirstLogin = data['isFirstLogin'] ?? false;

        if (token == null || token.isEmpty) {
          return LoginResult(success: false, message: "No token returned");
        }

        /// 🟢 Decode JWT
        List<String> roles = [];
        String? userId;
        String? employeeId;
        String? displayName;

        try {
          final t = JwtDecoder.decode(token);

          dynamic roleClaim =
              t['role'] ??
              t['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
              t['roles'];

          if (roleClaim is String) {
            roles = [roleClaim];
          } else if (roleClaim is List) {
            roles = roleClaim.map((r) => r.toString()).toList();
          }

          userId = _claim(t, [
            'sub',
            'userId',
            'uid',
            'nameid',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
          ]);
          employeeId = _claim(t, ['employeeId', 'empId']);
          displayName = _claim(t, [
            'name',
            'unique_name',
            'preferred_username',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name',
          ]);
        } catch (e) {
          print("❌ Failed to decode JWT: $e");
        }

        /// 💾 Save to secure storage
        await _secureStorage.write(key: "auth_token", value: token);
        await _secureStorage.write(key: "roles", value: jsonEncode(roles));
        if (userId != null)
          await _secureStorage.write(key: "user_id", value: userId);
        if (employeeId != null)
          await _secureStorage.write(key: "employee_id", value: employeeId);
        if (displayName != null)
          await _secureStorage.write(key: "display_name", value: displayName);

        print("🟦 Claims from token:");
        print("   userId: $userId");
        print("   employeeId: $employeeId");
        print("   displayName: $displayName");
        roles.forEach((r) => print("   role: $r"));

        return LoginResult(
          success: true,
          message: "Login successful",
          token: token,
          isFirstLogin: isFirstLogin,
          roles: roles,
        );
      } else {
        String msg = "Error: ${response.statusCode}";
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] is String) msg = body['message'];
        } catch (_) {}
        return LoginResult(success: false, message: msg);
      }
    } catch (e) {
      return LoginResult(
        success: false,
        message: "Could not connect to the server",
      );
    }
  }

  /// 🔹 Helpers (Getters)
  Future<String?> getToken() => _secureStorage.read(key: "auth_token");
  Future<String?> getApplicantId() => _secureStorage.read(key: "user_id");
  Future<String?> getEmployeeId() => _secureStorage.read(key: "employee_id");
  Future<String?> getDisplayName() => _secureStorage.read(key: "display_name");

  Future<List<String>> getRoles() async {
    final roleStr = await _secureStorage.read(key: "roles");
    if (roleStr == null) return [];
    try {
      final parsed = jsonDecode(roleStr);
      if (parsed is List) {
        return parsed.map((e) => e.toString()).toList();
      } else if (parsed is String) {
        return [parsed];
      }
    } catch (_) {}
    return [];
  }

  Future<String?> getApplicantIdFromStorage() async {
    return await _secureStorage.read(key: "applicant_id");
  }

  /// 🔹 Logout
  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }
}

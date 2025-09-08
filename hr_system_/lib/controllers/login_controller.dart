import 'dart:convert';
import 'package:flutter/material.dart';
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
      final response = await http.post(
        Uri.parse('http://192.168.1.223/api/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userName': input, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final isFirstLogin = data['isFirstLogin'] ?? false;

        String? role;
        if (token != null) {
          final decodedToken = JwtDecoder.decode(token);
          role =
              decodedToken['role'] ??
              decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
              decodedToken['roles'];
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
        return LoginResult(
          success: false,
          message: "Error: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      return LoginResult(
        success: false,
        message: "Could not connect to the server",
      );
    }
  }

  /// ✅ دالة لاسترجاع التوكن
  Future<String?> getToken() async {
    return await _secureStorage.read(key: "auth_token");
  }

  /// ✅ دالة لمسح التوكن (logout)
  Future<void> logout() async {
    await _secureStorage.delete(key: "auth_token");
  }
}

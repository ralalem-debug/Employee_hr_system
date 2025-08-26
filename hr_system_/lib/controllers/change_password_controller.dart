import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChangePasswordController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;

  // ✅ Secure storage instance
  final storage = const FlutterSecureStorage();

  Future<bool> changePassword(
    String newPassword,
    String confirmPassword,
  ) async {
    isLoading.value = true;
    errorMessage = null;

    try {
      final token = await storage.read(key: 'auth_token');

      if (token == null || token.isEmpty) {
        errorMessage = "Missing authentication token!";
        isLoading.value = false;
        return false;
      }

      final url = Uri.parse(
        'http://192.168.1.131:5005/api/Auth/change-password',
      );
      final res = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "accept": "application/json", // optional but safer
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
        try {
          final body = jsonDecode(res.body);
          errorMessage = body['message'] ?? "Failed to change password!";
        } catch (_) {
          errorMessage = "Failed to change password! (${res.statusCode})";
        }
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage = "Error: $e";
      return false;
    }
  }
}

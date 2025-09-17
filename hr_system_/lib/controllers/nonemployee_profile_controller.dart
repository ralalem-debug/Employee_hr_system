import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_system_/models/non_employee.dart/nonemployee_profile.dart';
import 'package:hr_system_/app_config.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var profile = Rxn<NonEmployeeProfile>();

  final storage = const FlutterSecureStorage();
  static const _timeout = Duration(seconds: 20);

  /// 🔹 جلب بيانات البروفايل
  Future<void> fetchProfile() async {
    isLoading.value = true;
    final token = await storage.read(key: "auth_token");

    if (token == null || token.isEmpty) {
      _showSnackbar("Error", "No token found. Please login again.", Colors.red);
      isLoading.value = false;
      return;
    }

    try {
      final res = await http
          .get(
            Uri.parse("${AppConfig.baseUrl}/nonemployees/profile"),
            headers: {
              "Authorization": "Bearer $token",
              "accept": "application/json",
            },
          )
          .timeout(_timeout);

      if (res.statusCode == 200) {
        profile.value = NonEmployeeProfile.fromJson(jsonDecode(res.body));
      } else {
        _showSnackbar(
          "Error",
          "Failed to load profile (${res.statusCode})",
          Colors.red,
        );
      }
    } on TimeoutException {
      _showSnackbar("Timeout", "Server took too long to respond.", Colors.red);
    } catch (e) {
      _showSnackbar("Error", "Network error: $e", Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 تحديث بيانات البروفايل
  Future<void> updateProfile({
    required String fullNameE,
    required String fullNameA,
    required String gender,
    required String city,
    required String email,
    required String phone,
    File? cvFile,
  }) async {
    isLoading.value = true;
    final token = await storage.read(key: "auth_token");

    if (token == null || token.isEmpty) {
      _showSnackbar("Error", "No token found. Please login again.", Colors.red);
      isLoading.value = false;
      return;
    }

    try {
      var request = http.MultipartRequest(
        "PUT",
        Uri.parse("${AppConfig.baseUrl}/nonemployees/profile"),
      );
      request.headers["Authorization"] = "Bearer $token";

      // ✅ البيانات الأساسية
      request.fields["FullNameE"] = fullNameE;
      request.fields["FullNameA"] = fullNameA;
      request.fields["Gender"] = gender;
      request.fields["City"] = city;
      request.fields["Email"] = email;
      request.fields["PhoneNumber"] = phone;

      // ✅ رفع CV لو تم اختياره
      if (cvFile != null) {
        request.files.add(await http.MultipartFile.fromPath("CV", cvFile.path));
      }

      var response = await request.send().timeout(_timeout);
      var body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        profile.value = NonEmployeeProfile.fromJson(jsonDecode(body));
        await fetchProfile(); // ✅ إعادة جلب للتأكيد
        _showSnackbar("Success", "Profile updated successfully!", Colors.green);
      } else {
        String serverMsg = body;
        try {
          final m = jsonDecode(body);
          if (m is Map && m['message'] is String) serverMsg = m['message'];
        } catch (_) {}
        _showSnackbar(
          "Error",
          "Failed to update profile: $serverMsg",
          Colors.red,
        );
      }
    } on TimeoutException {
      _showSnackbar("Timeout", "Server took too long to respond.", Colors.red);
    } catch (e) {
      _showSnackbar("Error", "Network error: $e", Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Snackbar ملونة
  void _showSnackbar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.withOpacity(0.2),
      colorText: Colors.black87,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }
}

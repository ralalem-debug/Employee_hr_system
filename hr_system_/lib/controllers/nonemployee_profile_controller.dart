import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_system_/models/non_employee.dart/nonemployee_profile.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var profile = Rxn<NonEmployeeProfile>();

  final storage = const FlutterSecureStorage();
  final baseUrl = "http://192.168.1.223";

  /// 🔹 جلب بيانات البروفايل
  Future<void> fetchProfile() async {
    isLoading.value = true;
    final token = await storage.read(key: "auth_token");

    if (token == null) {
      _showSnackbar("Error", "No token found. Please login again.", Colors.red);
      isLoading.value = false;
      return;
    }

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/nonemployees/profile"),
        headers: {
          "Authorization": "Bearer $token",
          "accept": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        profile.value = NonEmployeeProfile.fromJson(data);
      } else {
        _showSnackbar(
          "Error",
          "Failed to load profile (${res.statusCode})",
          Colors.red,
        );
      }
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

    if (token == null) {
      _showSnackbar("Error", "No token found. Please login again.", Colors.red);
      isLoading.value = false;
      return;
    }

    try {
      var request = http.MultipartRequest(
        "PUT",
        Uri.parse("$baseUrl/api/nonemployees/profile"),
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

      var response = await request.send();
      var body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);

        // نحدث البيانات بالرد
        profile.value = NonEmployeeProfile.fromJson(data);

        // نرجع نجيب البروفايل لضمان تحديث الـ CV وغيره
        await fetchProfile();

        _showSnackbar("Success", "Profile updated successfully!", Colors.green);
      } else {
        _showSnackbar(
          "Error",
          "Failed to update profile (${response.statusCode})",
          Colors.red,
        );
        print("❌ Response: $body");
      }
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

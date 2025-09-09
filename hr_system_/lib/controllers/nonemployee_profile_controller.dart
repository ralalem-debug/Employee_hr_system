import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_system_/models/non_employee.dart/nonemployee_profile.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var profile = Rxn<NonEmployeeProfile>(); // ✅ Getter profile موجود

  final storage = const FlutterSecureStorage();
  final baseUrl = "http://192.168.1.223";

  /// 🔹 جلب بيانات البروفايل
  Future<void> fetchProfile() async {
    isLoading.value = true;
    final token = await storage.read(key: "auth_token");

    if (token == null) {
      Get.snackbar("Error", "No token found. Please login again.");
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
        Get.snackbar("Error", "Failed to load profile (${res.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Error", "Network error: $e");
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
      Get.snackbar("Error", "No token found. Please login again.");
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
        profile.value = NonEmployeeProfile.fromJson(data);
        Get.snackbar("Success", "Profile updated successfully!");
      } else {
        Get.snackbar(
          "Error",
          "Failed to update profile (${response.statusCode})",
        );
        print("❌ Response: $body");
      }
    } catch (e) {
      Get.snackbar("Error", "Network error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

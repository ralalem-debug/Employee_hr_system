// lib/controller/jobs_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:hr_system_/models/jobs/job_mode.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JobsController extends GetxController {
  final String baseUrl = "http://192.168.1.223";
  final _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var jobs = <JobModel>[].obs;
  var appliedJobIds = <String>{}.obs;

  Future<String?> _getToken() => _storage.read(key: "auth_token");

  Future<void> fetchJobs() async {
    isLoading.value = true;
    jobs.clear();

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      isLoading.value = false;
      Get.snackbar("Error", "Missing token. Please login again.");
      return;
    }

    final url = Uri.parse("$baseUrl/api/jobs");
    try {
      final res = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        jobs.assignAll(data.map((e) => JobModel.fromJson(e)).toList());
      } else {
        Get.snackbar("Error", "Failed to load jobs (${res.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Network", "Failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyToJob(String jobId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar("Error", "Missing token. Please login again.");
      return;
    }

    final url = Uri.parse("$baseUrl/api/nonemployees/$jobId/apply");
    try {
      final res = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        appliedJobIds.add(jobId);
        Get.snackbar("Success", "Application submitted successfully ✅");
      } else {
        Get.snackbar("Error", "Apply failed (${res.statusCode})\n${res.body}");
      }
    } catch (e) {
      Get.snackbar("Network", "Failed: $e");
    }
  }
}

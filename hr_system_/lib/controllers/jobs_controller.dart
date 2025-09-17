// lib/controller/jobs_controller.dart
import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'package:hr_system_/models/jobs/job_mode.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../app_config.dart';

class JobsController extends GetxController {
  final _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var jobs = <JobModel>[].obs;
  var appliedJobIds = <String>{}.obs;

  static const _timeout = Duration(seconds: 15);

  Future<String?> _getToken() => _storage.read(key: "auth_token");

  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl); // ex: http://x.x.x.x/api
    final basePath =
        b.path.endsWith('/') ? b.path.substring(0, b.path.length - 1) : b.path;
    final addPath = path.startsWith('/') ? path.substring(1) : path;
    return b.replace(path: '$basePath/$addPath');
  }

  Map<String, String> _headers(String? token) => {
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Future<void> fetchJobs() async {
    isLoading.value = true;
    jobs.clear();

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      isLoading.value = false;
      Get.snackbar("Error", "Missing token. Please login again.");
      return;
    }

    try {
      final res = await http
          .get(_u('/jobs'), headers: _headers(token))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        jobs.assignAll(data.map((e) => JobModel.fromJson(e)).toList());
      } else if (res.statusCode == 401) {
        Get.snackbar("Unauthorized", "Please login again.");
      } else {
        Get.snackbar("Error", "Failed to load jobs (${res.statusCode})");
      }
    } on TimeoutException {
      Get.snackbar("Timeout", "Server did not respond in time.");
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

    try {
      final res = await http
          .post(_u('/nonemployees/$jobId/apply'), headers: _headers(token))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['message'] == "Application submitted successfully.") {
          appliedJobIds.add(jobId);
          Get.snackbar("Success", "You applied successfully!");
        }
      } else if (res.statusCode == 400) {
        appliedJobIds.add(jobId);
        Get.snackbar("Notice", "You have already applied to this job.");
      } else if (res.statusCode == 401) {
        Get.snackbar("Unauthorized", "Please login again.");
      } else {
        Get.snackbar("Error", "Unexpected error (${res.statusCode})");
      }
    } on TimeoutException {
      Get.snackbar("Timeout", "Server did not respond in time.");
    } catch (e) {
      Get.snackbar("Error", "Network error: $e");
    }
  }

  Future<JobModel?> fetchJobDetails(String jobId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar("Error", "Missing token. Please login again.");
      return null;
    }

    try {
      final res = await http
          .get(_u('/jobs/$jobId'), headers: _headers(token))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return JobModel.fromJson(data);
      } else if (res.statusCode == 401) {
        Get.snackbar("Unauthorized", "Please login again.");
        return null;
      } else {
        Get.snackbar("Error", "Failed to load details (${res.statusCode})");
        return null;
      }
    } on TimeoutException {
      Get.snackbar("Timeout", "Server did not respond in time.");
      return null;
    } catch (e) {
      Get.snackbar("Network", "Failed: $e");
      return null;
    }
  }
}

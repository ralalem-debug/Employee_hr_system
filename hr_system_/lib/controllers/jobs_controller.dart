// lib/controller/jobs_controller.dart
import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/login_controller.dart';
import 'package:hr_system_/models/jobs/job_mode.dart';
import 'package:hr_system_/models/non_employee.dart/upcoming_interview.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../app_config.dart';

class JobsController extends GetxController {
  final _storage = const FlutterSecureStorage();
  var upcomingInterviews = <UpcomingInterview>[].obs;
  var isLoading = false.obs;
  var jobs = <JobModel>[].obs;
  var appliedJobIds = <String>{}.obs;

  var selectedJobId = RxnString();

  static const _timeout = Duration(seconds: 15);

  Future<String?> _getToken() => _storage.read(key: "auth_token");

  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl); 
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
    try {
      final loginCtrl = LoginController();
      final token = await loginCtrl.getToken();

      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}/NonEmployees/$jobId/apply"),
        headers: {"Authorization": "Bearer $token"},
      );

      print("🔗 Apply URL: ${AppConfig.baseUrl}/NonEmployees/$jobId/apply");
      print("🔹 Status: ${res.statusCode}");
      print("🔹 Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // ✅ خزّن applicant_id
        if (data['applicant_id'] != null) {
          await const FlutterSecureStorage().write(
            key: "applicant_id",
            value: data['applicant_id'],
          );
          print("🟢 Saved applicant_id: ${data['applicant_id']}");
        }

        appliedJobIds.add(jobId);
        Get.snackbar("Success", "You applied successfully!");
      } else {
        Get.snackbar("Error", "Failed to apply: ${res.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
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

  Future<void> fetchUpcomingInterview() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar("Error", "Missing token. Please login again.");
      return;
    }

    try {
      final res = await http
          .get(_u('/nonemployees/upcoming'), headers: _headers(token))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        upcomingInterviews.assignAll(
          data.map((e) => UpcomingInterview.fromJson(e)).toList(),
        );
      } else if (res.statusCode == 401) {
        Get.snackbar("Unauthorized", "Please login again.");
      } else {
        Get.snackbar(
          "Error",
          "Failed to load upcoming interviews (${res.statusCode})",
        );
      }
    } on TimeoutException {
      Get.snackbar("Timeout", "Server did not respond in time.");
    } catch (e) {
      Get.snackbar("Network", "Failed: $e");
    }
  }

  /// ✅ دالة لتخزين الـ Job ID
  void setSelectedJob(String jobId) {
    selectedJobId.value = jobId;
    print("📌 Selected Job ID: $jobId");
  }
}

// controllers/salary_advance_list_controller.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Dashboard/salary_advance_model.dart';
import '../../app_config.dart';

class SalaryAdvanceListController extends GetxController {
  var requests = <SalaryAdvanceModel>[].obs;
  var isLoading = false.obs;
  var error = RxnString();

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();
  static const _timeout = Duration(seconds: 15);

  Future<String?> _getToken() => storage.read(key: 'auth_token');

  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl); // ex: http://x.x.x.x/api
    final basePath =
        b.path.endsWith('/') ? b.path.substring(0, b.path.length - 1) : b.path;
    final addPath = path.startsWith('/') ? path.substring(1) : path;
    return b.replace(path: '$basePath/$addPath');
  }

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Future<void> fetchRequests() async {
    isLoading.value = true;
    error.value = null;

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      error.value = "Unauthorized. Please login again.";
      isLoading.value = false;
      return;
    }

    try {
      final res = await http
          .get(_u('/SalaryAdvance/employee-requests'), headers: _headers(token))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        List<dynamic> data = json.decode(res.body);
        requests.value =
            data.map((e) => SalaryAdvanceModel.fromJson(e)).toList();
      } else if (res.statusCode == 401) {
        error.value = "Unauthorized. Please login again.";
      } else {
        error.value = "Error fetching requests: ${res.body}";
      }
    } on TimeoutException {
      error.value = "Connection timeout, please try again.";
    } catch (e) {
      error.value = "Connection error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRequest(String requestId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar(
        "Unauthorized",
        "Please login again",
        backgroundColor: Colors.red.shade50,
      );
      return;
    }

    try {
      final res = await http
          .delete(_u('/SalaryAdvance/$requestId'), headers: _headers(token))
          .timeout(_timeout);

      if (res.statusCode == 200 || res.statusCode == 204) {
        requests.removeWhere((req) => req.salaryAdvanceRequestId == requestId);
        Get.snackbar(
          "Deleted",
          "Request deleted successfully",
          backgroundColor: Colors.green.shade50,
        );
      } else if (res.statusCode == 401) {
        Get.snackbar(
          "Unauthorized",
          "Please login again",
          backgroundColor: Colors.red.shade50,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to delete request: ${res.body}",
          backgroundColor: Colors.red.shade50,
        );
      }
    } on TimeoutException {
      Get.snackbar(
        "Error",
        "Connection timeout",
        backgroundColor: Colors.red.shade50,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Connection error: $e",
        backgroundColor: Colors.red.shade50,
      );
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/Dashboard/complaint_model.dart';
import '../../app_config.dart';

class ComplaintsListController extends GetxController {
  var complaints = <ComplaintModel>[].obs;
  var isLoading = false.obs;
  var error = RxnString();

  final storage = const FlutterSecureStorage();

  Future<String?> _getToken() => storage.read(key: 'auth_token');

  Uri _u(String path) => Uri.parse('${AppConfig.baseUrl}$path');

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  /// 📨 جلب الشكاوى
  Future<void> fetchComplaints() async {
    isLoading.value = true;
    error.value = null;

    final token = await _getToken();

    try {
      final res = await http
          .get(_u('/complaints/employee-complaints'), headers: _headers(token))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data is List) ? data : (data['items'] ?? []);
        complaints.value =
            list
                .map<ComplaintModel>((e) => ComplaintModel.fromJson(e))
                .toList();
      } else if (res.statusCode == 401) {
        error.value = "Unauthorized. Please login again.";
      } else {
        error.value = "Error ${res.statusCode}: ${res.body}";
      }
    } catch (e) {
      error.value = "Connection error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  /// ❌ حذف شكوى
  Future<void> deleteComplaint(String complaintId) async {
    final token = await _getToken();

    try {
      final res = await http
          .delete(
            _u('/complaints/delete/$complaintId'),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        complaints.removeWhere((c) => c.complaintId == complaintId);
        Get.snackbar(
          "Deleted",
          "Complaint deleted successfully",
          backgroundColor: Colors.green.shade50,
        );
      } else if (res.statusCode == 401) {
        Get.snackbar(
          "Error",
          "Unauthorized",
          backgroundColor: Colors.red.shade50,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to delete complaint (${res.statusCode})",
          backgroundColor: Colors.red.shade50,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Connection error: $e",
        backgroundColor: Colors.red.shade50,
      );
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Dashboard/salary_advance_model.dart';

class SalaryAdvanceListController extends GetxController {
  var requests = <SalaryAdvanceModel>[].obs;
  var isLoading = false.obs;
  var error = RxnString();

  static const String getUrl =
      'http://192.168.1.128:5000/api/SalaryAdvance/employee-requests';
  static const String deleteUrl =
      'http://192.168.1.128:5000/api/SalaryAdvance/';

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  Future<void> fetchRequests() async {
    isLoading.value = true;
    error.value = null;

    final token = await storage.read(key: 'auth_token') ?? '';

    try {
      final response = await http.get(
        Uri.parse(getUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        requests.value =
            data.map((e) => SalaryAdvanceModel.fromJson(e)).toList();
      } else {
        error.value = "Error fetching requests: ${response.body}";
      }
    } catch (e) {
      error.value = "Connection error: $e";
    }
    isLoading.value = false;
  }

  Future<void> deleteRequest(String requestId) async {
    final token = await storage.read(key: 'auth_token') ?? '';

    try {
      final response = await http.delete(
        Uri.parse('$deleteUrl$requestId'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        requests.removeWhere((req) => req.salaryAdvanceRequestId == requestId);
        Get.snackbar(
          "Deleted",
          "Request deleted successfully",
          backgroundColor: Colors.green.shade50,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to delete request",
          backgroundColor: Colors.red.shade50,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Connection error",
        backgroundColor: Colors.red.shade50,
      );
    }
  }
}

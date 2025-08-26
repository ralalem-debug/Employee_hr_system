import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/Dashboard/complaint_model.dart';

class ComplaintsListController extends GetxController {
  var complaints = <ComplaintModel>[].obs;
  var isLoading = false.obs;
  var error = RxnString();

  static const String getUrl =
      'http://192.168.1.131:5005/api/complaints/employee-complaints';
  static const String deleteUrl =
      'http://192.168.1.131:5005/api/complaints/delete/';

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  Future<void> fetchComplaints() async {
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
        complaints.value = data.map((e) => ComplaintModel.fromJson(e)).toList();
      } else {
        error.value = "Error fetching complaints: ${response.body}";
      }
    } catch (e) {
      error.value = "Connection error: $e";
    }
    isLoading.value = false;
  }

  Future<void> deleteComplaint(String complaintId) async {
    final token = await storage.read(key: 'auth_token') ?? '';

    try {
      final response = await http.delete(
        Uri.parse('$deleteUrl$complaintId'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        complaints.removeWhere(
          (complaint) => complaint.complaintId == complaintId,
        );
        Get.snackbar(
          "Deleted",
          "Complaint deleted successfully",
          backgroundColor: Colors.green.shade50,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to delete complaint",
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

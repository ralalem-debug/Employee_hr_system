import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/Dashboard/complaint_model.dart';

class ComplaintController extends GetxController {
  final subjectController = TextEditingController();
  final detailsController = TextEditingController();

  var isSent = false.obs;
  var isLoading = false.obs;
  var error = RxnString();

  static const String apiUrl =
      'http://192.168.1.128:5000/api/complaints/send-complaint';

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  Future<void> sendComplaint() async {
    final subject = subjectController.text.trim();
    final details = detailsController.text.trim();

    if (subject.isEmpty || details.isEmpty) {
      error.value = "Please fill in all fields.";
      return;
    }

    isLoading.value = true;
    error.value = null;

    final token = await storage.read(key: 'auth_token') ?? '';

    final complaint = ComplaintModel(subject: subject, details: details);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(complaint.toJson()),
      );

      if (response.statusCode == 200) {
        isSent.value = true;
        error.value = null;
        subjectController.clear();
        detailsController.clear();
      } else {
        error.value = "Error sending complaint: ${response.body}";
      }
    } catch (e) {
      error.value = "Connection error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void resetStatus() {
    isSent.value = false;
    error.value = null;
  }

  @override
  void onClose() {
    subjectController.dispose();
    detailsController.dispose();
    super.onClose();
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/Dashboard/complaint_model.dart';
import '../../app_config.dart';

class ComplaintController extends GetxController {
  final subjectController = TextEditingController();
  final detailsController = TextEditingController();

  var isSent = false.obs;
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

  Future<void> sendComplaint() async {
    final subject = subjectController.text.trim();
    final details = detailsController.text.trim();

    if (subject.isEmpty || details.isEmpty) {
      error.value = "Please fill in all fields.";
      return;
    }

    isLoading.value = true;
    isSent.value = false;
    error.value = null;

    final token = await _getToken();
    final complaint = ComplaintModel(subject: subject, details: details);

    try {
      final res = await http
          .post(
            _u('/complaints/send-complaint'),
            headers: _headers(token),
            body: jsonEncode(complaint.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 201) {
        isSent.value = true;
        subjectController.clear();
        detailsController.clear();
        error.value = null;
      } else if (res.statusCode == 401) {
        error.value = "Not authorized. Please login again.";
      } else {
        // حاول نقرأ رسالة من السيرفر إن وُجدت
        String msg = res.body;
        try {
          final m = jsonDecode(res.body);
          if (m is Map && m['message'] is String) msg = m['message'];
          if (m is Map && m['error'] is String) msg = m['error'];
        } catch (_) {}
        error.value = "Error ${res.statusCode}: $msg";
      }
    } on Exception catch (e) {
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

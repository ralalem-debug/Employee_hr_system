// controllers/salary_advance_controller.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Dashboard/salary_advance_model.dart';
import '../../app_config.dart';

class SalaryAdvanceController extends GetxController {
  final amountController = TextEditingController();
  final monthController = TextEditingController();

  var isSent = false.obs;
  var isLoading = false.obs;
  var error = RxnString();

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  static const _timeout = Duration(seconds: 15);

  Future<String?> _getToken() => storage.read(key: 'auth_token');

  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl); // مثال: http://x.x.x.x/api
    final basePath =
        b.path.endsWith('/')
            ? b.path.substring(0, b.path.length - 1)
            : b.path; // "/api"
    final addPath =
        path.startsWith('/') ? path.substring(1) : path; // "SalaryAdvance/..."
    return b.replace(path: '$basePath/$addPath'); // "/api/SalaryAdvance/..."
  }

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Future<void> sendRequest() async {
    final amountText = amountController.text.trim();
    final month = monthController.text.trim();

    if (amountText.isEmpty || month.isEmpty) {
      error.value = "Please fill in all fields.";
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      error.value = "Please enter a valid amount.";
      return;
    }

    isLoading.value = true;
    isSent.value = false;
    error.value = null;

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      error.value = "Unauthorized. Please login again.";
      isLoading.value = false;
      return;
    }

    final salaryAdvance = SalaryAdvanceModel(
      amount: amount,
      deductFromMonth: month,
      subject: "Salary Advance",
    );

    try {
      final res = await http
          .post(
            _u('/SalaryAdvance/send-request'),
            headers: _headers(token),
            body: jsonEncode(salaryAdvance.toJson()),
          )
          .timeout(_timeout);

      if (res.statusCode == 200 || res.statusCode == 201) {
        isSent.value = true;
        amountController.clear();
        monthController.clear();
        error.value = null;
      } else if (res.statusCode == 401) {
        error.value = "Unauthorized. Please login again.";
      } else {
        String msg = res.body;
        try {
          final m = jsonDecode(res.body);
          if (m is Map && m['message'] is String) msg = m['message'];
          if (m is Map && m['error'] is String) msg = m['error'];
        } catch (_) {}
        error.value = "Error ${res.statusCode}: $msg";
      }
    } on TimeoutException {
      error.value = "Connection timeout. Please try again.";
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
    amountController.dispose();
    monthController.dispose();
    super.onClose();
  }
}

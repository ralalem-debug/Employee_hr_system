import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/Dashboard/salary_advance_model.dart';

class SalaryAdvanceController extends GetxController {
  final amountController = TextEditingController();
  final monthController = TextEditingController();

  var isSent = false.obs;
  var isLoading = false.obs;
  var error = RxnString();

  static const String apiUrl =
      'http://192.168.1.213/api/SalaryAdvance/send-request';

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
    error.value = null;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final salaryAdvance = SalaryAdvanceModel(
      amount: amount,
      deductFromMonth: month,
      subject: "Salary Advance",
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(salaryAdvance.toJson()),
      );

      if (response.statusCode == 200) {
        isSent.value = true;
        error.value = null;
        amountController.clear();
        monthController.clear();
      } else {
        error.value = "Error submitting request: ${response.body}";
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
    amountController.dispose();
    monthController.dispose();
    super.onClose();
  }
}

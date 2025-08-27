// controllers/resignation_request_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/models/Dashboard/resignation_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ResignationRequestController extends GetxController {
  final noteController = TextEditingController();
  final lastWorkingDayController = TextEditingController();

  var isLoading = false.obs;
  var isSent = false.obs;
  var error = RxnString();

  static const String apiUrl =
      'http://192.168.1.128:5000/api/resignations/send-resignation';

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  Future<void> sendResignation() async {
    final note = noteController.text.trim();
    final lastWorkingDay = lastWorkingDayController.text.trim();

    if (lastWorkingDay.isEmpty) {
      error.value = "Please select your last working day.";
      return;
    }

    isLoading.value = true;
    error.value = null;

    final token = await storage.read(key: 'auth_token') ?? '';

    final resignation = ResignationRequestModel(
      note: note,
      lastWorkingDay: lastWorkingDay,
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(resignation.toJson()),
      );

      if (response.statusCode == 200) {
        isSent.value = true;
        error.value = null;
        noteController.clear();
        lastWorkingDayController.clear();
      } else {
        error.value = "Error: ${response.body}";
      }
    } catch (e) {
      error.value = "Connection error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    noteController.dispose();
    lastWorkingDayController.dispose();
    super.onClose();
  }
}

// controllers/overtime_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Dashboard/overtime_model.dart';

class OvertimeController extends GetxController {
  final dateController = TextEditingController();
  final taskController = TextEditingController();
  final fromTimeController = TextEditingController();
  final toTimeController = TextEditingController();
  final hoursController = TextEditingController();
  var isHoliday = false.obs;

  var isSent = false.obs;
  var isLoading = false.obs;
  var error = RxnString();

  static const String apiUrl =
      'http://192.168.1.223/api/overtime/employee/send-request';

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  Future<void> sendOvertime() async {
    final date = dateController.text.trim();
    final task = taskController.text.trim();
    final fromTime = fromTimeController.text.trim();
    final toTime = toTimeController.text.trim();
    final hours = int.tryParse(hoursController.text.trim()) ?? 0;
    final holiday = isHoliday.value;

    if (date.isEmpty ||
        task.isEmpty ||
        fromTime.isEmpty ||
        toTime.isEmpty ||
        hours == 0) {
      error.value = "Please fill in all fields correctly.";
      return;
    }

    isLoading.value = true;
    error.value = null;

    final token = await storage.read(key: 'auth_token') ?? '';

    final overtime = OvertimeModel(
      date: date,
      task: task,
      fromTime: fromTime,
      toTime: toTime,
      hours: hours,
      isHoliday: holiday,
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(overtime.toJson()),
      );

      if (response.statusCode == 200) {
        isSent.value = true;
        error.value = null;
        dateController.clear();
        taskController.clear();
        fromTimeController.clear();
        toTimeController.clear();
        hoursController.clear();
        isHoliday.value = false;
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
    dateController.dispose();
    taskController.dispose();
    fromTimeController.dispose();
    toTimeController.dispose();
    hoursController.dispose();
    super.onClose();
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Dashboard/overtime_model.dart';
import '../../app_config.dart';

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

  final storage = const FlutterSecureStorage();

  Future<String?> _getToken() => storage.read(key: 'auth_token');

  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl); // مثال: http://192.168.1.158/api
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

    final token = await _getToken();

    final overtime = OvertimeModel(
      date: date,
      task: task,
      fromTime: fromTime,
      toTime: toTime,
      hours: hours,
      isHoliday: holiday,
    );

    try {
      final res = await http
          .post(
            _u('/overtime/employee/send-request'),
            headers: _headers(token),
            body: jsonEncode(overtime.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 201) {
        isSent.value = true;
        dateController.clear();
        taskController.clear();
        fromTimeController.clear();
        toTimeController.clear();
        hoursController.clear();
        isHoliday.value = false;
        error.value = null;
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

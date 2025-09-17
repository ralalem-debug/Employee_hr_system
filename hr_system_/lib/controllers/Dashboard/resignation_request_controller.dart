// controllers/resignation_request_controller.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/models/Dashboard/resignation_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../app_config.dart';

class ResignationRequestController extends GetxController {
  final noteController = TextEditingController();
  final lastWorkingDayController = TextEditingController();

  var isLoading = false.obs;
  var isSent = false.obs;
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
        path.startsWith('/') ? path.substring(1) : path; // "resignations/..."
    return b.replace(path: '$basePath/$addPath'); // "/api/resignations/..."
  }

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Future<void> sendResignation() async {
    final note = noteController.text.trim();
    final lastWorkingDay = lastWorkingDayController.text.trim();

    if (lastWorkingDay.isEmpty) {
      error.value = "Please select your last working day.";
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

    final resignation = ResignationRequestModel(
      note: note,
      lastWorkingDay: lastWorkingDay,
    );

    try {
      final res = await http
          .post(
            _u('/resignations/send-resignation'),
            headers: _headers(token),
            body: jsonEncode(resignation.toJson()),
          )
          .timeout(_timeout);

      if (res.statusCode == 200 || res.statusCode == 201) {
        isSent.value = true;
        noteController.clear();
        lastWorkingDayController.clear();
        error.value = null;
      } else if (res.statusCode == 401) {
        error.value = "Unauthorized. Please login again.";
      } else {
        // جرّب نطلع رسالة خطأ مفيدة من السيرفر
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

  @override
  void onClose() {
    noteController.dispose();
    lastWorkingDayController.dispose();
    super.onClose();
  }
}

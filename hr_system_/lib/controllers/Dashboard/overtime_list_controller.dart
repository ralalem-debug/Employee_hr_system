// controllers/overtime_list_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Dashboard/overtime_model.dart';
import '../../app_config.dart';

class OvertimeListController extends GetxController {
  var isLoading = false.obs;
  var error = RxnString();
  var overtimeRequests = <OvertimeModel>[].obs;

  final storage = const FlutterSecureStorage();

  Future<String?> _getToken() => storage.read(key: 'auth_token');

  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl);
    final basePath =
        b.path.endsWith('/') ? b.path.substring(0, b.path.length - 1) : b.path;
    final addPath = path.startsWith('/') ? path.substring(1) : path;
    return b.replace(path: '$basePath/$addPath');
  }

  Map<String, String> _headers(String? token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Future<void> fetchRequests() async {
    isLoading.value = true;
    error.value = null;

    final token = await _getToken();

    try {
      final res = await http
          .get(_u('/overtime/employee/overtime-list'), headers: _headers(token))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body is List ? body : (body['items'] ?? []);
        overtimeRequests.value =
            list.map((e) => OvertimeModel.fromJson(e)).toList();
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

  Future<void> deleteRequest(String overtimeId) async {
    final token = await _getToken();

    try {
      final res = await http
          .delete(
            _u('/overtime/employee/delete/$overtimeId'),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        overtimeRequests.removeWhere((o) => o.overtimeId == overtimeId);
      } else {
        Get.snackbar(
          "Error",
          "Could not delete request: ${res.body}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.errorContainer,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Connection error: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
      );
    }
  }
}

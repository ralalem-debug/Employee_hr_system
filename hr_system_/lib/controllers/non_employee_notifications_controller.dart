import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'package:hr_system_/models/non_employee.dart/notification_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_system_/app_config.dart';

class NotificationController extends GetxController {
  var isLoading = false.obs;
  var notifications = <NotificationModel>[].obs;

  final storage = const FlutterSecureStorage();
  static const _timeout = Duration(seconds: 15);

  Future<String?> _getToken() => storage.read(key: "auth_token");

  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl);
    final basePath =
        b.path.endsWith('/') ? b.path.substring(0, b.path.length - 1) : b.path;
    final addPath = path.startsWith('/') ? path.substring(1) : path;
    return b.replace(path: '$basePath/$addPath');
  }

  Map<String, String> _headers(String token) => {
    "Authorization": "Bearer $token",
    "accept": "application/json",
  };

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    notifications.clear();

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar("Error", "No token found, please login again.");
      isLoading.value = false;
      return;
    }

    try {
      final res = await http
          .get(_u("/Auth/my-notifications"), headers: _headers(token))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        notifications.value =
            data.map((n) => NotificationModel.fromJson(n)).toList();
      } else if (res.statusCode == 401) {
        Get.snackbar("Unauthorized", "Please login again.");
      } else {
        Get.snackbar(
          "Error",
          "Failed to load notifications (${res.statusCode})",
        );
      }
    } on TimeoutException {
      Get.snackbar("Timeout", "Server did not respond in time.");
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

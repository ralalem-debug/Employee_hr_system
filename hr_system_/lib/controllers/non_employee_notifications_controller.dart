import 'dart:convert';
import 'package:get/get.dart';
import 'package:hr_system_/models/non_employee.dart/notification_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationController extends GetxController {
  var isLoading = false.obs;
  var notifications = <NotificationModel>[].obs;

  final storage = const FlutterSecureStorage();
  final baseUrl = "http://192.168.1.223";

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    final token = await storage.read(key: "auth_token");

    if (token == null) {
      Get.snackbar("Error", "No token found, please login again.");
      isLoading.value = false;
      return;
    }

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/Auth/my-notifications"),
        headers: {
          "Authorization": "Bearer $token",
          "accept": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);

        notifications.value =
            data
                .map(
                  (n) => NotificationModel.fromJson(n as Map<String, dynamic>),
                )
                .toList();
      } else {
        Get.snackbar("Error", "Failed to load notifications");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

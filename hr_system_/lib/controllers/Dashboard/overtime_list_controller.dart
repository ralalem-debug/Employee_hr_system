// controllers/overtime_list_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Dashboard/overtime_model.dart';

class OvertimeListController extends GetxController {
  var isLoading = false.obs;
  var error = RxnString();
  var overtimeRequests = <OvertimeModel>[].obs;

  static const String apiUrl =
      'http://192.168.1.213:5000/api/overtime/employee/overtime-list';

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  Future<void> fetchRequests() async {
    isLoading.value = true;
    error.value = null;
    final token = await storage.read(key: 'auth_token') ?? '';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        overtimeRequests.value =
            data.map((e) => OvertimeModel.fromJson(e)).toList();
      } else {
        error.value = "Error fetching requests: ${response.body}";
      }
    } catch (e) {
      error.value = "Connection error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRequest(String overtimeId) async {
    final token = await storage.read(key: 'auth_token') ?? '';
    final url =
        'http://192.168.1.213:5000/api/overtime/employee/delete/$overtimeId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        overtimeRequests.removeWhere(
          (element) => element.overtimeId == overtimeId,
        );
      } else {
        Get.snackbar(
          "Error",
          "Could not delete request: ${response.body}",
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

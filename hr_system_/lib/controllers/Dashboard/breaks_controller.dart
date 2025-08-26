import 'package:get/get.dart';
import 'package:hr_system_/models/Dashboard/breaks_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BreakController extends GetxController {
  var breaks = <BreakModel>[].obs;
  var isLoading = false.obs;
  var error = "".obs;
  String? currentBreakReportId;

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  @override
  void onInit() {
    fetchBreaks();
    super.onInit();
  }

  Future<String?> _getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<void> fetchBreaks() async {
    isLoading.value = true;
    error.value = "";
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        error.value = "Not authorized. Please login again.";
        isLoading.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse("http://192.168.1.131:5005/api/Breaks"),
        headers: {"Authorization": "Bearer $token", "accept": "*/*"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        breaks.value = List<BreakModel>.from(
          data.map((x) => BreakModel.fromJson(x)),
        );
      } else if (response.statusCode == 401) {
        error.value = "Session expired. Please login again.";
      } else {
        error.value = "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      error.value = "Network error: $e";
    }
    isLoading.value = false;
  }

  // Start break
  Future<String?> startBreak(String breakId) async {
    final token = await _getToken();
    if (token == null) return null;

    final res = await http.post(
      Uri.parse('http://192.168.1.131:5005/api/Breaks/start-break'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'accept': '*/*',
      },
      body: jsonEncode(breakId), // note: just the breakId as string!
    );
    print('Status: ${res.statusCode}');
    print('Body: ${res.body}');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      currentBreakReportId = data['breakReportId'];
      return data['breakReportId'];
    } else {
      return null;
    }
  }

  // End break
  Future<String?> endBreak(String breakReportId) async {
    final token = await _getToken();
    if (token == null) return null;

    final res = await http.post(
      Uri.parse('http://192.168.1.131:5005/api/Breaks/end-break'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'accept': '*/*',
      },
      body: jsonEncode(breakReportId),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      currentBreakReportId = null;
      return data['duration'];
    } else {
      return null;
    }
  }

  Future<Duration?> getRemainingTime(String breakId) async {
    final token = await _getToken();
    if (token == null) return null;
    final res = await http.get(
      Uri.parse(
        'http://192.168.1.131:5005/api/Breaks/breaks/$breakId/remaining-time',
      ),
      headers: {'Authorization': 'Bearer $token', 'accept': '*/*'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      final parts =
          (data['remainingTime'] ?? "00:00:00")
              .split(":")
              .map(int.parse)
              .toList();
      if (parts.length == 3) {
        return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
      }
    }
    return null;
  }
}

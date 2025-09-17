import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:hr_system_/app_config.dart';
import 'package:hr_system_/models/Dashboard/breaks_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BreakController extends GetxController {
  var breaks = <BreakModel>[].obs;
  var isLoading = false.obs;
  var error = "".obs;

  String? currentBreakReportId;
  final storage = const FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    fetchBreaks();
  }

  // ---------------- helpers ----------------
  Future<String?> _getToken() => storage.read(key: 'auth_token');

  Uri _u(String path) => Uri.parse('${AppConfig.baseUrl}$path');

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // ---------------- API calls ----------------
  Future<void> fetchBreaks() async {
    isLoading.value = true;
    error.value = "";
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        error.value = "Not authorized. Please login again.";
        return;
      }

      final res = await http
          .get(_u('/Breaks'), headers: _headers(token))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data is List) ? data : (data['items'] ?? []);
        breaks.value = List<BreakModel>.from(
          list.map((x) => BreakModel.fromJson(x)),
        );
      } else if (res.statusCode == 401) {
        error.value = "Session expired. Please login again.";
      } else {
        error.value = "Error ${res.statusCode}: ${res.body}";
      }
    } on TimeoutException {
      error.value = "Request timed out. Please try again.";
    } catch (e) {
      error.value = "Network error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  /// Start break
  Future<String?> startBreak(String breakId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return null;

    final res = await http
        .post(
          _u('/Breaks/start-break'),
          headers: _headers(token),
          // إذا الـ API عندكم يتوقع "string خام" خليه كما هو:
          body: jsonEncode(breakId),
          // ولو يتوقع JSON مثل {"breakId": "..."} بدّلي للسطر:
          // body: jsonEncode({"breakId": breakId}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      currentBreakReportId = data['breakReportId'];
      return currentBreakReportId;
    }
    return null;
  }

  /// End break
  Future<String?> endBreak(String breakReportId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return null;

    final res = await http
        .post(
          _u('/Breaks/end-break'),
          headers: _headers(token),
          body: jsonEncode(breakReportId),
          // أو: body: jsonEncode({"breakReportId": breakReportId}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      currentBreakReportId = null;
      return data['duration']?.toString();
    }
    return null;
  }

  /// Remaining time
  Future<Duration?> getRemainingTime(String breakId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return null;

    final res = await http
        .get(
          _u('/Breaks/breaks/$breakId/remaining-time'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final hhmmss = (data['remainingTime'] ?? "00:00:00") as String;
      final parts = hhmmss.split(':');
      if (parts.length == 3) {
        return Duration(
          hours: int.tryParse(parts[0]) ?? 0,
          minutes: int.tryParse(parts[1]) ?? 0,
          seconds: int.tryParse(parts[2]) ?? 0,
        );
      }
    }
    return null;
  }
}

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../app_config.dart';
import '../models/attendance_model.dart';

class AttendanceController {
  final storage = const FlutterSecureStorage();
  static const _timeout = Duration(seconds: 15);

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
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Future<String?> fetchAndSaveUserId() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final res = await http
          .get(_u('/Auth/myId'), headers: _headers(token))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final userId = json['id'] ?? json['userId'];
        if (userId != null) {
          await storage.write(key: 'user_id', value: userId.toString());
          print("✅ Saved userId: $userId");
          return userId.toString();
        }
      }
      print("⚠️ Failed to fetch userId: ${res.body}");
      return null;
    } catch (e) {
      print("❌ Exception fetchAndSaveUserId: $e");
      return null;
    }
  }

  Future<AttendanceModel?> checkAtOffice() async {
    String? userId = await storage.read(key: 'user_id');
    final token = await _getToken();

    if (userId == null || userId.isEmpty) {
      userId = await fetchAndSaveUserId();
    }

    if (userId == null || userId.isEmpty) {
      print("❌ No userId available");
      return null;
    }

    try {
      final url = "http://192.168.1.247:8001/at-office/$userId";
      print("📡 Calling office-status API: $url");

      final headers = {'Accept': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final res = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(_timeout);

      print("🔎 Response status: ${res.statusCode}");
      print("🔎 Response body: ${res.body}");

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return AttendanceModel.fromJson(json);
      } else {
        return null;
      }
    } catch (e) {
      print("❌ Exception checkAtOffice: $e");
      return null;
    }
  }
}

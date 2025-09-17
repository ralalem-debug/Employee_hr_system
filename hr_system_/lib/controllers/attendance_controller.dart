import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/attendance_model.dart';
import '../app_config.dart';

class AttendanceController {
  // ✅ Secure storage instance
  final storage = const FlutterSecureStorage();
  static const _timeout = Duration(seconds: 15);

  Future<String?> _getToken() => storage.read(key: 'auth_token');

  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl); // مثال: http://192.168.1.158/api
    final basePath =
        b.path.endsWith('/') ? b.path.substring(0, b.path.length - 1) : b.path;
    final addPath = path.startsWith('/') ? path.substring(1) : path;
    return b.replace(path: '$basePath/$addPath');
  }

  Map<String, String> _headers(String? token) => {
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  /// (CheckIn, CheckOut, TotalHours)
  Future<AttendanceModel?> fetchCheckInOutTime() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final res = await http
          .get(_u('/attendance/checkInOut-time'), headers: _headers(token))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return AttendanceModel.fromJson(json);
      }
      return null;
    } on TimeoutException {
      print("⏱️ Timeout while fetching checkInOut-time");
      return null;
    } catch (e) {
      print("❌ Exception fetchCheckInOutTime: $e");
      return null;
    }
  }

  /// ✅ تسجيل الحضور
  Future<DateTime?> doCheckIn() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final res = await http
          .post(_u('/attendance/checkin'), headers: _headers(token))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        String? checkInStr = json['checkInTime'];
        if (checkInStr != null) {
          final now = DateTime.now();
          final parts = checkInStr.split(":");
          return DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
        return DateTime.now();
      }
      return null;
    } catch (e) {
      print("❌ Exception doCheckIn: $e");
      return null;
    }
  }

  /// ✅ تسجيل الانصراف
  Future<DateTime?> doCheckOut() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final res = await http
          .post(_u('/attendance/checkout'), headers: _headers(token))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        String? checkOutStr = json['checkOutTime'];
        if (checkOutStr != null) {
          final now = DateTime.now();
          final parts = checkOutStr.split(":");
          return DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
        return DateTime.now();
      }
      return null;
    } catch (e) {
      print("❌ Exception doCheckOut: $e");
      return null;
    }
  }

  /// ✅ التأكد من أن الموظف موجود في المكتب (حسب الكاميرات)
  Future<bool> checkAtOffice() async {
    final userId = await storage.read(key: 'user_id');
    if (userId == null || userId.isEmpty) return false;

    try {
      // هذا endpoint مختلف عن الـ baseUrl (يشتغل على service ثانية)
      final url =
          'http://192.168.1.164:8000/m/v1/office-status/$userId'; // لو حابب نخليه برضو configurable نحطه في AppConfig
      final res = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final body = res.body.trim();
        return body == '1';
      }
      return false;
    } catch (e) {
      print("❌ Exception checkAtOffice: $e");
      return false;
    }
  }
}

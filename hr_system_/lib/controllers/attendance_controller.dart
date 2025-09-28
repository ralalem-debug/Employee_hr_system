import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/attendance_model.dart';

class AttendanceController {
  final storage = const FlutterSecureStorage();
  static const _timeout = Duration(seconds: 15);

  Future<String?> _getToken() => storage.read(key: 'auth_token');

  Map<String, String> _headers(String? token) => {
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  /// ✅ دالة بسيطة ترجع إذا الموظف موجود أو لا
  Future<bool> isAtOffice(String userId) async {
    try {
      final res = await http
          .get(Uri.parse("http://192.168.1.170:8001/at-office/$userId"))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json is Map<String, dynamic> && json.containsKey("isAtOffice")) {
          return json["isAtOffice"] == true;
        }
      }
      return false;
    } catch (e) {
      print("❌ Error isAtOffice: $e");
      return false;
    }
  }

  Future<AttendanceModel?> getCheckInOutTime() async {
    final token = await _getToken();
    try {
      final res = await http
          .get(
            Uri.parse(
              "http://192.168.1.158:5000/api/attendance/checkInOut-time",
            ),
            headers: _headers(token),
          )
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return AttendanceModel.fromJson(json);
      }
      return null;
    } catch (e) {
      print("❌ Error getCheckInOutTime: $e");
      return null;
    }
  }

  Future<bool> doCheckIn() async {
    final token = await _getToken();
    try {
      final res = await http
          .post(
            Uri.parse("http://192.168.1.158:5000/api/attendance/checkin"),
            headers: _headers(token),
          )
          .timeout(_timeout);

      return res.statusCode == 200;
    } catch (e) {
      print("❌ Error doCheckIn: $e");
      return false;
    }
  }

  Future<bool> doCheckOut() async {
    final token = await _getToken();
    try {
      final res = await http
          .post(
            Uri.parse("http://192.168.1.158:5000/api/attendance/checkout"),
            headers: _headers(token),
          )
          .timeout(_timeout);

      return res.statusCode == 200;
    } catch (e) {
      print("❌ Error doCheckOut: $e");
      return false;
    }
  }
}

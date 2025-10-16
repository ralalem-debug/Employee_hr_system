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

  Future<bool> isAtOffice(String userId) async {
    try {
      final res = await http
          .get(Uri.parse("http://46.185.162.66:30217/at-office/$userId"))
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

  // ✅ الحصول على وقت CheckIn و CheckOut
  Future<AttendanceModel?> getCheckInOutTime() async {
    final token = await _getToken();
    try {
      final res = await http
          .get(
            Uri.parse(
              "http://46.185.162.66:30211/api/attendance/checkInOut-time",
            ),
            headers: _headers(token),
          )
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return AttendanceModel.fromJson(json);
      } else {
        print("❌ Error ${res.statusCode}: ${res.body}");
      }
      return null;
    } catch (e) {
      print("❌ Error getCheckInOutTime: $e");
      return null;
    }
  }

  // ✅ تنفيذ Check-in
  Future<bool> doCheckIn() async {
    final token = await _getToken();
    try {
      final res = await http
          .post(
            Uri.parse("http://46.185.162.66:30211/api/attendance/checkin"),
            headers: _headers(token),
          )
          .timeout(_timeout);

      if (res.statusCode == 200) {
        print("✅ Check-in successful");
        return true;
      } else {
        print("❌ Failed Check-in: ${res.statusCode} ${res.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error doCheckIn: $e");
      return false;
    }
  }

  // ✅ تنفيذ Check-out
  Future<bool> doCheckOut() async {
    final token = await _getToken();
    try {
      final res = await http
          .post(
            Uri.parse("http://46.185.162.66:30211/api/attendance/checkout"),
            headers: _headers(token),
          )
          .timeout(_timeout);

      if (res.statusCode == 200) {
        print("✅ Check-out successful");
        return true;
      } else {
        print("❌ Failed Check-out: ${res.statusCode} ${res.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error doCheckOut: $e");
      return false;
    }
  }
}

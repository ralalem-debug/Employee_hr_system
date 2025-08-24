import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_model.dart';

class AttendanceController {
  final String baseUrl = 'http://192.168.1.213/api/attendance';

  /// ✅ جلب بيانات اليوم (CheckIn, CheckOut, TotalHours)
  Future<AttendanceModel?> fetchCheckInOutTime() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) return null;

    final url = '$baseUrl/checkInOut-time';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return AttendanceModel.fromJson(json);
    }
    return null;
  }

  /// ✅ تسجيل الحضور
  Future<DateTime?> doCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) return null;

    final url = '$baseUrl/checkin';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // ممكن يرجع "checkInTime": "09:09:34"
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
  }

  /// ✅ تسجيل الانصراف
  Future<DateTime?> doCheckOut() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) return null;

    final url = '$baseUrl/checkInOut-time';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // ممكن يرجع "checkOutTime": "14:11:08"
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
  }

  /// ✅ التأكد من أن الموظف مسجّل في النظام (حسب ID)
  Future<bool> checkAtOffice() async {
    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getString('employee_id');
    final userId = prefs.getString('user_id');
    final idToUse =
        (employeeId != null && employeeId.isNotEmpty) ? employeeId : userId;

    if (idToUse == null || idToUse.isEmpty) return false;

    final url =
        'http://192.168.1.127:8000/api/registered_users?user_id=$idToUse';
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {'accept': 'application/json'},
      );
      if (res.statusCode == 200) {
        return res.body.trim() == '1';
      }
      return false;
    } catch (e) {
      print("DEBUG >>> Exception while calling API: $e");
      return false;
    }
  }
}

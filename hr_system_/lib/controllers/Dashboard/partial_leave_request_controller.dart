import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hr_system_/models/Dashboard/partial_leave_request.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../app_config.dart'; // ← تأكد من المسار حسب مشروعك

class LeaveRequestController {
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  DateTime? selectedDate;

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  static const _timeout = Duration(seconds: 15);

  LeaveRequestController() {
    final now = DateTime.now();
    fromTime = TimeOfDay(hour: now.hour, minute: now.minute);
    selectedDate = now;
    startTimeController.text = _formatTime(fromTime!);
    dateController.text = _formatDate(now);
  }

  // يبني URI آمنًا اعتمادًا على AppConfig.baseUrl + path
  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl); // مثلا: http://192.168.1./api
    final basePath =
        b.path.endsWith('/')
            ? b.path.substring(0, b.path.length - 1)
            : b.path; // "/api"
    final addPath =
        path.startsWith('/') ? path.substring(1) : path; // "employee/..."
    return b.replace(path: '$basePath/$addPath'); // "/api/employee/..."
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final ampm = t.hour >= 12 ? "PM" : "AM";
    final minute = t.minute.toString().padLeft(2, '0');
    return "$hour:$minute $ampm";
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  Future<void> pickTime(BuildContext context, bool isFrom) async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime:
          isFrom ? (fromTime ?? TimeOfDay.now()) : (toTime ?? TimeOfDay.now()),
    );
    if (time != null) {
      if (isFrom) {
        fromTime = time;
        startTimeController.text = _formatTime(time);
      } else {
        toTime = time;
        endTimeController.text = _formatTime(time);
      }
    }
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      selectedDate = date;
      dateController.text = _formatDate(date);
    }
  }

  /// تحويل TimeOfDay إلى Duration منذ منتصف الليل
  Duration? _timeOfDayToDuration(TimeOfDay? t) {
    if (t == null) return null;
    return Duration(hours: t.hour, minutes: t.minute);
  }

  Future<void> submit(BuildContext context) async {
    if (selectedDate == null ||
        fromTime == null ||
        toTime == null ||
        reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('all fields are required')));
      return;
    }

    // تحقق أن وقت النهاية > وقت البداية
    final fromDur = _timeOfDayToDuration(fromTime!)!;
    final toDur = _timeOfDayToDuration(toTime!)!;
    if (toDur <= fromDur) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final request = PartialLeaveRequest(
      date: selectedDate!,
      fromTime: fromDur,
      toTime: toDur,
      reason: reasonController.text.trim(),
    );

    // ✅ قراءة التوكن من SecureStorage
    final jwtToken = await storage.read(key: 'auth_token');
    if (jwtToken == null || jwtToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إعادة تسجيل الدخول')),
      );
      return;
    }

    final url = _u('/employee/request-partial-day-leave');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $jwtToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      // لوج مفيد للتشخيص
      // ignore: avoid_print
      print("URL: $url");
      // ignore: avoid_print
      print("STATUS: ${response.statusCode}");
      // ignore: avoid_print
      print("BODY: ${response.body}");

      String message = 'Request submitted successfully';

      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey('message')) {
            message = decoded['message'].toString();
          }
        } catch (e) {
          // ignore: avoid_print
          print("⚠️ JSON parse error: $e");
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        Navigator.pop(context);
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unauthorized. Please login again.')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل إرسال الطلب: $message')));
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection timeout, please try again')),
      );
    } catch (e) {
      // ignore: avoid_print
      print("❌ Request error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في الاتصال: $e')));
    }
  }
}

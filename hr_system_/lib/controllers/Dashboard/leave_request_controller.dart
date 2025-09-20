import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../../app_config.dart';

class LeaveRequestController {
  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl);
    final basePath =
        b.path.endsWith('/')
            ? b.path.substring(0, b.path.length - 1)
            : b.path; // "/api"
    final addPath =
        path.startsWith('/') ? path.substring(1) : path; // "employee/..."
    return b.replace(path: '$basePath/$addPath'); // "/api/employee/..."
  }

  Future<http.Response> submitLeaveRequest({
    required String token,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String comments,
    File? document,
  }) async {
    final uri = _u('/employee/request-leave');
    final request = http.MultipartRequest('POST', uri);

    // هيدر المصادقة + تلميح أننا نريد JSON
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // الحقول (نصية دائمًا في multipart)
    request.fields['LeaveType'] = leaveType;

    // إذا الـ API يتوقع تاريخ فقط "yyyy-MM-dd" استخدمي السطر التالي بدل ISO:
    // final start = startDate.toIso8601String().split('T').first;
    // final end   = endDate.toIso8601String().split('T').first;
    request.fields['StartDate'] = startDate.toIso8601String();
    request.fields['EndDate'] = endDate.toIso8601String();

    request.fields['Comments'] = comments;

    // ملف مرفق (اختياري)
    if (document != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'Document',
          document.path,
          filename: p.basename(document.path),
          // لو بدك تحددي content-type استعملي http_parser:
          // contentType: MediaType('application', 'pdf')
        ),
      );
    }

    // إرسال + تحويل النتيجة إلى http.Response مع مهلة
    final streamed = await request.send().timeout(const Duration(seconds: 20));
    final res = await http.Response.fromStream(streamed);

    // (اختياري) اعتبري 200 أو 201 نجاح
    if (res.statusCode == 200 || res.statusCode == 201) {
      return res;
    }
    // ارمي استثناء ليسهل التعامل مع الخطأ من الـ UI
    throw Exception('Leave request failed: ${res.statusCode} ${res.body}');
  }
}

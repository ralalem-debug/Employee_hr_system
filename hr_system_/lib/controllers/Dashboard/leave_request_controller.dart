import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class LeaveRequestController {
  Future<http.Response> submitLeaveRequest({
    required String token,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String comments,
    File? document,
  }) async {
    final uri = Uri.parse('http://192.168.1.128/api/employee/request-leave');
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['LeaveType'] = leaveType;
    request.fields['StartDate'] = startDate.toIso8601String();
    request.fields['EndDate'] = endDate.toIso8601String();
    request.fields['Comments'] = comments;

    if (document != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'Document',
          document.path,
          filename: basename(document.path),
        ),
      );
    }

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}

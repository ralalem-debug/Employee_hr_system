import 'dart:convert';
import 'dart:async';
import 'package:hr_system_/models/Dashboard/partial_leave_list.dart';
import 'package:http/http.dart' as http;

class PartialLeaveListController {
  static const String BASE_HOST = '192.168.1.213:5000';
  static const Duration _timeout = Duration(seconds: 20);

  Map<String, String> _headers(String jwt) => {
    'Authorization': 'Bearer $jwt',
    'accept': 'application/json',
  };

  Future<List<PartialDayLeaveModel>> fetchLeaves({
    required String? jwtToken,
    String? sortBy,
    String? order,
  }) async {
    if (jwtToken == null || jwtToken.isEmpty) {
      throw Exception('Missing JWT token');
    }

    final queryParams = <String, String>{};
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (order != null) queryParams['order'] = order;

    final uri = Uri.http(
      BASE_HOST,
      '/api/employee/list-of-partial-day-leaves',
      queryParams,
    );

    final response = await http
        .get(uri, headers: _headers(jwtToken))
        .timeout(_timeout);

    print("GET $uri");
    print("STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      try {
        final body = response.body.isEmpty ? '[]' : response.body;
        final List list = jsonDecode(body) as List;

        if (list.isNotEmpty && list.first is Map) {
          final Map first = list.first as Map;
          print("Keys(first): ${first.keys}");
          print("leaveStartTime(first): ${first['leaveStartTime']}");
          print("leaveEndTime(first): ${first['leaveEndTime']}");
          print("actualLeaveDuration(first): ${first['actualLeaveDuration']}");
        }

        return list.map<PartialDayLeaveModel>((e) {
          final model = PartialDayLeaveModel.fromJson(
            e as Map<String, dynamic>,
          );

          final dur = (e['actualLeaveDuration'] ?? '').toString().trim();
          if (dur.isNotEmpty) {
            model.actualLeaveDuration = dur;
          }
          return model;
        }).toList();
      } catch (e) {
        throw Exception('Failed to parse leaves: $e');
      }
    } else {
      throw Exception(
        'Failed to load leaves: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<bool> cancelPartialDayLeave(
    String partialLeaveId,
    String jwtToken,
  ) async {
    final uri = Uri.http(BASE_HOST, '/api/employee/cancel-partial-day-leave');

    final response = await http
        .post(
          uri,
          headers: {..._headers(jwtToken), 'Content-Type': 'application/json'},
          body: jsonEncode({'partialLeaveId': partialLeaveId}),
        )
        .timeout(_timeout);

    print("POST $uri");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<String?> startPartialDayLeave(String leaveId, String jwtToken) async {
    final uri = Uri.http(
      BASE_HOST,
      '/api/employee/start-partial-leave/$leaveId',
    );

    final res = await http
        .post(uri, headers: _headers(jwtToken))
        .timeout(_timeout);

    print("POST $uri");
    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    if (res.statusCode == 200 || res.statusCode == 201) {
      try {
        if (res.body.isEmpty) return null;
        final Map<String, dynamic> m = jsonDecode(res.body);
        final startedAt = (m['leaveStartTime'] ?? '').toString().trim();
        return startedAt.isEmpty ? null : startedAt; // ex: "11:49"
      } catch (_) {
        return null;
      }
    }
    throw Exception('Start failed: ${res.statusCode} ${res.body}');
  }

  /// ينهي الإجازة الجزئية. يبقى يرجّع bool حتى لا نكسر الواجهة.
  /// لو الـ BODY يحتوي leaveEndTime/actualLeaveDuration رح نطبعهم للـ Logs.
  Future<bool> endPartialDayLeave(String leaveId, String jwtToken) async {
    final uri = Uri.http(BASE_HOST, '/api/employee/end-partial-leave/$leaveId');

    final response = await http
        .post(uri, headers: _headers(jwtToken))
        .timeout(_timeout);

    print("POST $uri");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> m = jsonDecode(response.body);
          final endAt = (m['leaveEndTime'] ?? '').toString().trim();
          final dur = (m['actualLeaveDuration'] ?? '').toString().trim();
          if (endAt.isNotEmpty) print("Parsed leaveEndTime: $endAt");
          if (dur.isNotEmpty) print("Parsed actualLeaveDuration: $dur");
          // تقدر ترجعهم بدل الـ bool لو حبيت تعدّل الواجهة لاحقًا
        }
      } catch (_) {
        // تجاهل بارسنغ خاطئ، المهم رجع 200
      }
      return true;
    }

    throw Exception('End failed: ${response.statusCode} ${response.body}');
  }
}

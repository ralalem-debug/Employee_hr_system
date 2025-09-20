import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../app_config.dart';
import 'package:hr_system_/models/Dashboard/partial_leave_list.dart';

class PartialLeaveListController {
  static const Duration _timeout = Duration(seconds: 20);

  Uri _u(String path, [Map<String, String>? qp]) {
    final b = Uri.parse(AppConfig.baseUrl);
    // تأكد أن baseUrl يحتوي "http://IP:5000/api"

    // نظف الـ path
    final addPath = path.startsWith('/') ? path.substring(1) : path;
    return b.replace(
      path: "${b.path.replaceAll(RegExp(r'/$'), '')}/$addPath",
      queryParameters: qp?.isNotEmpty == true ? qp : null,
    );
  }

  Map<String, String> _headers(String jwt) => {
    'Authorization': 'Bearer $jwt',
    'Accept': 'application/json',
  };

  Future<List<PartialDayLeaveModel>> fetchLeaves({
    required String? jwtToken,
    String? sortBy,
    String? order,
  }) async {
    if (jwtToken == null || jwtToken.isEmpty) {
      throw Exception('Missing JWT token');
    }

    final qp = <String, String>{};
    if (sortBy != null) qp['sortBy'] = sortBy;
    if (order != null) qp['order'] = order;

    final uri = _u('/employee/list-of-partial-day-leaves', qp);

    final response = await http
        .get(uri, headers: _headers(jwtToken))
        .timeout(_timeout);

    print("GET $uri");
    print("STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      try {
        final raw = response.body.isEmpty ? '[]' : response.body;
        final decoded = jsonDecode(raw);
        final List list =
            decoded is List ? decoded : (decoded['items'] ?? []) as List;

        if (list.isNotEmpty && list.first is Map) {
          final Map first = list.first as Map;
          print("Keys(first): ${first.keys}");
          print("leaveStartTime(first): ${first['leaveStartTime']}");
          print("leaveEndTime(first): ${first['leaveEndTime']}");
          print("actualLeaveDuration(first): ${first['actualLeaveDuration']}");
        }

        return list.map<PartialDayLeaveModel>((e) {
          final m = e as Map<String, dynamic>;
          final model = PartialDayLeaveModel.fromJson(m);
          final dur = (m['actualLeaveDuration'] ?? '').toString().trim();
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
    final uri = _u('/employee/cancel-partial-day-leave');

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
    final uri = _u('/employee/start-partial-leave/$leaveId');

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

  /// ينهي الإجازة الجزئية. يرجّع bool (نجاح/فشل) للحفاظ على الواجهة.
  /// لو الـ BODY يحتوي leaveEndTime/actualLeaveDuration بنطبعهم للّوجز.
  Future<bool> endPartialDayLeave(String leaveId, String jwtToken) async {
    final uri = _u('/employee/end-partial-leave/$leaveId');

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
        }
      } catch (_) {
        // تجاهل parsing error، المهم الكود نجاح
      }
      return true;
    }

    throw Exception('End failed: ${response.statusCode} ${response.body}');
  }
}

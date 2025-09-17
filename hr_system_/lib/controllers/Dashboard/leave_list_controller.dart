import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../app_config.dart';
import '../../models/Dashboard/leave_request_list_model.dart';

class LeaveListController {
  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  // يبني URI بالاعتماد على AppConfig.baseUrl + path + query params
  Uri _u(String path, [Map<String, String>? qp]) {
    final b = Uri.parse(AppConfig.baseUrl); // مثال: http://192.168.1.158/api
    final basePath =
        b.path.endsWith('/')
            ? b.path.substring(0, b.path.length - 1)
            : b.path; // -> "/api"
    final addPath =
        path.startsWith('/') ? path.substring(1) : path; // "employee/..."
    return b.replace(
      path: '$basePath/$addPath', // -> "/api/employee/..."
      queryParameters: (qp != null && qp.isNotEmpty) ? qp : null,
    );
  }

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  Future<List<LeaveRequestModel>> fetchLeaveRequests({
    String? sortBy,
    String? order,
  }) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found!');
    }

    final qp = <String, String>{};
    if (sortBy != null) qp['sortBy'] = sortBy;
    if (order != null) qp['order'] = order;

    final uri = _u('/employee/list-of-leave-requests', qp);

    final res = await http
        .get(uri, headers: _headers(token))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);

      // السيرفر قد يرجّع List مباشرة أو كائن فيه items
      final List list = body is List ? body : (body['items'] ?? []);
      return list
          .map<LeaveRequestModel>((e) => LeaveRequestModel.fromJson(e))
          .toList();
    } else if (res.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception(
        'Failed to load leave requests: '
        '${res.statusCode} ${res.body}',
      );
    }
  }
}

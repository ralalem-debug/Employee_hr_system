import 'dart:convert';
import 'package:hr_system_/models/Dashboard/leave_request_list_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LeaveListController {
  Future<List<LeaveRequestModel>> fetchLeaveRequests({
    String? sortBy,
    String? order,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('No token found!');

    final queryParams = <String, String>{};
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (order != null) queryParams['order'] = order;

    final uri = Uri.http(
      '192.168.1.131:5005',
      '/api/employee/list-of-leave-requests',
      queryParams,
    );

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => LeaveRequestModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load leave requests: ${res.body}');
    }
  }
}

import 'dart:convert';
import 'dart:async';
import 'package:hr_system_/models/calendar_holiday_model.dart';
import 'package:http/http.dart' as http;
import '../app_config.dart';

class HolidayEventsController {
  static const _timeout = Duration(seconds: 15);

  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl); // ex: http://192.168.1.158/api
    final basePath =
        b.path.endsWith('/') ? b.path.substring(0, b.path.length - 1) : b.path;
    final addPath = path.startsWith('/') ? path.substring(1) : path;
    return b.replace(path: '$basePath/$addPath');
  }

  Future<List<HolidayEventModel>> fetchEvents(String jwtToken) async {
    try {
      final res = await http
          .get(
            _u('/attendance/employee/calendar'),
            headers: {
              'Authorization': 'Bearer $jwtToken',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(res.body);
        return jsonList.map((e) => HolidayEventModel.fromJson(e)).toList();
      } else if (res.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load events: ${res.statusCode} ${res.body}');
      }
    } on TimeoutException {
      throw Exception('Connection timeout while loading events');
    } catch (e) {
      throw Exception('Error loading events: $e');
    }
  }
}

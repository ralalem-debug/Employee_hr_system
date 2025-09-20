import 'dart:convert';
import 'dart:async';
import 'package:hr_system_/models/calendar_holiday_model.dart';
import 'package:http/http.dart' as http;
import '../app_config.dart';

class HolidayEventsController {
  static const _timeout = Duration(seconds: 15);

  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl);
    final basePath =
        b.path.endsWith('/') ? b.path.substring(0, b.path.length - 1) : b.path;
    final addPath = path.startsWith('/') ? path.substring(1) : path;
    return b.replace(path: '$basePath/$addPath');
  }

  Future<List<HolidayEventModel>> fetchEvents(String jwtToken) async {
    try {
      final url = _u('/attendance/employee/calendar');
      print("📅 Fetching events from: $url");

      final res = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $jwtToken',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      print("📥 Response [${res.statusCode}]: ${res.body}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        if (decoded is List) {
          return decoded.map((e) => HolidayEventModel.fromJson(e)).toList();
        } else if (decoded is Map && decoded.containsKey("data")) {
          final List<dynamic> jsonList = decoded["data"];
          return jsonList.map((e) => HolidayEventModel.fromJson(e)).toList();
        } else {
          throw Exception("Unexpected response format: $decoded");
        }
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

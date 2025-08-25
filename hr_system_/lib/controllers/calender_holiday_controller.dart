import 'dart:convert';
import 'package:hr_system_/models/calendar_holiday_model.dart';
import 'package:http/http.dart' as http;

class HolidayEventsController {
  Future<List<HolidayEventModel>> fetchEvents(String jwtToken) async {
    final url = 'http://192.168.1.131:5005/api/attendance/employee/calendar';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $jwtToken', 'accept': '*/*'},
    );
    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((e) => HolidayEventModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }
}

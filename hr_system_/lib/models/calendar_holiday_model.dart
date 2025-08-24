class HolidayEventModel {
  final DateTime date;
  final String title;
  final String type;
  final String? status;
  final String? timeRange;

  HolidayEventModel({
    required this.date,
    required this.title,
    required this.type,
    this.status,
    this.timeRange,
  });

  factory HolidayEventModel.fromJson(Map<String, dynamic> json) {
    return HolidayEventModel(
      date: DateTime.parse(json['date']),
      title: json['title'],
      type: json['type'],
      status: json['status'],
      timeRange: json['timeRange'],
    );
  }
}

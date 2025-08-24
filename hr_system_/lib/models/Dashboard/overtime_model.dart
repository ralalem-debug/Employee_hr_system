// models/overtime_model.dart
class OvertimeModel {
  final String? overtimeId;
  final String date;
  final String task;
  final String fromTime;
  final String toTime;
  final int hours;
  final bool isHoliday;
  final String? status;

  OvertimeModel({
    this.overtimeId,
    required this.date,
    required this.task,
    required this.fromTime,
    required this.toTime,
    required this.hours,
    required this.isHoliday,
    this.status,
  });

  factory OvertimeModel.fromJson(Map<String, dynamic> json) {
    return OvertimeModel(
      overtimeId: json['overtimeId'],
      date: json['date'],
      task: json['task'],
      fromTime: json['fromTime'],
      toTime: json['toTime'],
      hours: json['hours'],
      isHoliday: json['isHoliday'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    "date": date,
    "task": task,
    "fromTime": fromTime,
    "toTime": toTime,
    "hours": hours,
    "isHoliday": isHoliday,
  };
}

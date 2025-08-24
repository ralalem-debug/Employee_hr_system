class PartialLeaveRequest {
  final DateTime date;
  final Duration fromTime;
  final Duration toTime;
  final String reason;

  PartialLeaveRequest({
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    "date": date.toIso8601String(),
    "fromTime": {"ticks": fromTime.inMicroseconds * 10},
    "toTime": {"ticks": toTime.inMicroseconds * 10},
    "reason": reason,
  };
}

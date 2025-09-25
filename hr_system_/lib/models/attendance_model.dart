class AttendanceModel {
  // من at-office
  final String userId;
  final bool isAtOffice;
  final DateTime? checkInAt;
  final DateTime? lastUpdated;
  final int? minutesOnline;

  // من checkInOut-time
  final String? checkInTime;
  final String? checkOutTime;
  final String? totalHours;

  AttendanceModel({
    this.userId = "",
    this.isAtOffice = false,
    this.checkInAt,
    this.lastUpdated,
    this.minutesOnline,
    this.checkInTime,
    this.checkOutTime,
    this.totalHours,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      // من at-office
      userId: json['userId'] ?? "",
      isAtOffice: json['isAtOffice'] ?? false,
      checkInAt:
          json['checkInAt'] != null
              ? DateTime.tryParse(json['checkInAt'])
              : null,
      lastUpdated:
          json['lastUpdated'] != null
              ? DateTime.tryParse(json['lastUpdated'])
              : null,
      minutesOnline: json['minutesOnline'],

      // من checkInOut-time
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      totalHours: json['totalHours'],
    );
  }

  /// 🔹 عدد الدقائق المحسوبة حياً من وقت CheckIn
  int get liveMinutesOnline {
    if (checkInAt == null) return 0;
    return DateTime.now().difference(checkInAt!).inMinutes;
  }
}

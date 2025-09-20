class AttendanceModel {
  final String userId;
  final bool isAtOffice;
  final DateTime? checkInAt;
  final DateTime? lastUpdated;
  final int? minutesOnline; // من السيرفر (قيمة snapshot)

  AttendanceModel({
    required this.userId,
    required this.isAtOffice,
    this.checkInAt,
    this.lastUpdated,
    this.minutesOnline,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
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
    );
  }

  /// يحسب المدة من وقت CheckIn حتى الآن
  String get liveMinutesOnline {
    if (checkInAt == null) return "--:--";
    final diff = DateTime.now().difference(checkInAt!);
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    return "${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}";
  }
}

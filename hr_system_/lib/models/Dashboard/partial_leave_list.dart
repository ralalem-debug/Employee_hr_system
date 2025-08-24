class PartialDayLeaveModel {
  // ثابتة (من الطلب)
  final String partialLeaveId;
  final String leaveDate;
  final String fromTime;
  final String toTime;
  final String hours;
  final String reason;
  final String requestStatus;

  // فعلية (نريدها قابلة للتحديث بعد Start/End)
  String? leaveStartTime; // actual start
  String? leaveEndTime; // actual end
  String? actualLeaveDuration; // actual duration

  bool get isApproved => requestStatus.trim().toLowerCase() == 'approved';
  bool get hasStarted => (leaveStartTime ?? '').isNotEmpty;
  bool get hasEnded => (leaveEndTime ?? '').isNotEmpty;

  PartialDayLeaveModel({
    required this.partialLeaveId,
    required this.leaveDate,
    required this.fromTime,
    required this.toTime,
    required this.hours,
    required this.reason,
    required this.requestStatus,
    this.leaveStartTime,
    this.leaveEndTime,
    this.actualLeaveDuration,
  });

  factory PartialDayLeaveModel.fromJson(Map<String, dynamic> json) {
    String? _nullIfEmpty(dynamic v) {
      final s = (v ?? '').toString().trim();
      return s.isEmpty ? null : s;
    }

    return PartialDayLeaveModel(
      partialLeaveId: (json['partialLeaveId'] ?? '').toString(),
      leaveDate: (json['leaveDate'] ?? '').toString(),
      fromTime: (json['fromTime'] ?? '').toString(),
      toTime: (json['toTime'] ?? '').toString(),
      hours: (json['hours'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      requestStatus: (json['requestStatus'] ?? '').toString(),
      leaveStartTime: _nullIfEmpty(json['leaveStartTime']),
      leaveEndTime: _nullIfEmpty(json['leaveEndTime']),
      actualLeaveDuration: _nullIfEmpty(json['actualLeaveDuration']),
    );
  }
}

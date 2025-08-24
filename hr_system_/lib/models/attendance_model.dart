class AttendanceModel {
  final String? checkInTime;
  final String? checkOutTime;
  final String? totalHours;

  AttendanceModel({this.checkInTime, this.checkOutTime, this.totalHours});

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      totalHours: json['totalHours'],
    );
  }
}

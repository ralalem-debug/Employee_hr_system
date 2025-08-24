class LeaveRequestModel {
  final String leaveRequestId;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String comments;
  final String? documentUrl;

  LeaveRequestModel({
    required this.leaveRequestId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.comments,
    this.documentUrl,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      leaveRequestId: json['leaveRequestId'],
      leaveType: json['leaveType'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
      comments: json['comments'] ?? '',
      documentUrl: json['documentPath'],
    );
  }
}

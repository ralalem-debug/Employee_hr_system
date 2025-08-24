class LeaveRequestModel {
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String comments;

  LeaveRequestModel({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.comments,
  });
}

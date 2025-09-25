class UpcomingInterview {
  final String interviewId;
  final String scheduledAt;
  final String meetingLink;
  final String status;
  final String jobTitle;
  final String interviewerName;

  UpcomingInterview({
    required this.interviewId,
    required this.scheduledAt,
    required this.meetingLink,
    required this.status,
    required this.jobTitle,
    required this.interviewerName,
  });

  factory UpcomingInterview.fromJson(Map<String, dynamic> json) {
    return UpcomingInterview(
      interviewId: json['interviewId'] ?? '',
      scheduledAt: json['scheduledAt'] ?? '',
      meetingLink: json['meetingLink'] ?? '',
      status: json['status'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      interviewerName: json['interviewerName'] ?? '',
    );
  }
}

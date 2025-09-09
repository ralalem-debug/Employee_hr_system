class NotificationModel {
  final String notificationId;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ?? "",
      title: json['title'] ?? "",
      message: json['message'] ?? "",
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] ?? "",
    );
  }
}

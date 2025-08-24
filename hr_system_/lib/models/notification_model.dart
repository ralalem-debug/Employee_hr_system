class AppNotification {
  final String notificationId;
  final String title;
  final String message;
  final String date;
  final bool isRead;

  AppNotification({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      notificationId: json['notificationId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      date: json['createdAt']?.toString().split('T').first ?? '',
      isRead: json['isRead'] ?? false,
    );
  }
}

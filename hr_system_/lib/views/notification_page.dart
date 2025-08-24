import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/views/employee_nav_bar.dart';
import '../../controllers/notifications_controller.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsController controller = Get.put(NotificationsController());

  @override
  void initState() {
    super.initState();
    controller.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final all = controller.notifications;
        final unread = all.where((n) => !n.isRead).toList();
        final read = all.where((n) => n.isRead).toList();

        if (all.isEmpty) {
          return const Center(child: Text("No notifications available."));
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (unread.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "New",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...unread
                  .map((n) => _notificationCard(n, isUnread: true))
                  .toList(),
              const Divider(height: 32),
            ],
            if (read.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "Earlier",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...read
                  .map((n) => _notificationCard(n, isUnread: false))
                  .toList(),
            ],
          ],
        );
      }),
      bottomNavigationBar: const EmployeeNavBar(currentIndex: 2),
    );
  }

  Widget _notificationCard(AppNotification notif, {required bool isUnread}) {
    return GestureDetector(
      onTap: () {
        if (isUnread) {
          controller.markAsReadLocally(notif.notificationId);
        }
      },

      child: Card(
        color: isUnread ? const Color(0xFFF1F8FF) : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              isUnread
                  ? BorderSide(color: Colors.blueAccent.shade100)
                  : BorderSide.none,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Icon(
            Icons.notifications,
            color: isUnread ? Colors.blue : Colors.grey,
            size: 30,
          ),
          title: Text(
            notif.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notif.message),
              const SizedBox(height: 4),
              Text(
                notif.date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

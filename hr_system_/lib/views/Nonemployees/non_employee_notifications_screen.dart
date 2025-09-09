import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/non_employee_notifications_controller.dart';
import 'package:hr_system_/models/non_employee.dart/notification_model.dart';
import 'package:hr_system_/views/Nonemployees/custom_nav_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController _c = Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    _c.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.blue,
      ),
      body: Obx(() {
        if (_c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_c.notifications.isEmpty) {
          return const Center(child: Text("No notifications found."));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _c.notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final NotificationModel n = _c.notifications[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: n.isRead ? Colors.grey.shade200 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: n.isRead ? Colors.black54 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n.message,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        n.createdAt,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2), // ✅ Tab notify
    );
  }
}

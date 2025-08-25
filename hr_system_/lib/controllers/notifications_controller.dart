import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationsController extends GetxController {
  var notifications = <AppNotification>[].obs;
  var isLoading = true.obs;
  Timer? _timer;

  List<String> _readIds = [];

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      fetchNotifications();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  ///  حفظ الإشعار كمقروء وتخزينه محلياً
  Future<void> markAsReadLocally(String notificationId) async {
    final index = notifications.indexWhere(
      (n) => n.notificationId == notificationId,
    );

    if (index != -1 && !notifications[index].isRead) {
      final notif = notifications[index];
      notifications[index] = AppNotification(
        notificationId: notif.notificationId,
        title: notif.title,
        message: notif.message,
        date: notif.date,
        isRead: true,
      );

      _readIds.add(notificationId);
      await _saveReadNotificationIds();
    }
  }

  Future<void> fetchNotifications() async {
    const url = 'http://192.168.1.131:5005/api/Auth/my-notifications';

    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      await _loadReadNotificationIds();

      if (token == null || token.isEmpty) {
        Get.snackbar("Unauthorized", "Authentication token is missing");
        isLoading.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        final List<dynamic> list = jsonData['notifications'] ?? [];

        final filtered =
            list.where((json) {
              return json['isAdmin'] == false;
            }).toList();

        notifications.value =
            filtered.map((json) {
              final notif = AppNotification.fromJson(json);
              return AppNotification(
                notificationId: notif.notificationId,
                title: notif.title,
                message: notif.message,
                date: notif.date,
                isRead: _readIds.contains(notif.notificationId),
              );
            }).toList();
      } else {
        Get.snackbar(
          "Error",
          "Failed to load notifications (${response.statusCode})",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
      print('Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  ///  تحميل قائمة الـ IDs المقروءة من SharedPreferences
  Future<void> _loadReadNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    _readIds = prefs.getStringList('read_notifications') ?? [];
  }

  ///  حفظ قائمة المقروءات في SharedPreferences
  Future<void> _saveReadNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('read_notifications', _readIds);
  }
}

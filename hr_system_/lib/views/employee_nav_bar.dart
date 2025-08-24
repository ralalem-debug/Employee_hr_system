import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/views/notification_page.dart';
import 'package:hr_system_/views/profile/profile_screen.dart';
import 'package:hr_system_/views/settings_page.dart';
import '../controllers/notifications_controller.dart';
import 'home_screen.dart';
import 'Dashboard/dashboard_screen.dart';

class EmployeeNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const EmployeeNavBar({Key? key, required this.currentIndex, this.onTap})
    : super(key: key);

  static final List<Widget Function()> _screens = [
    () => HomeScreen(),
    () => DashboardScreen(),
    () => NotificationsScreen(),
    () => ProfileScreen(),
    () => SettingsScreen(),
  ];

  void _handleTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => _screens[index]()));
    if (onTap != null) onTap!(index);
  }

  @override
  Widget build(BuildContext context) {
    final NotificationsController notifController = Get.put(
      NotificationsController(),
    ); // Required for badge
    final items = [
      _NavBarItem(Icons.home_rounded, "HOME"),
      _NavBarItem(Icons.dashboard_customize_outlined, "DASHBOARD"),
      _NavBarItem(Icons.notifications_none_rounded, "NOTIFICATIONS"),
      _NavBarItem(Icons.person, "PROFILE"),
      _NavBarItem(Icons.settings, "SETTINGS"),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Material(
          elevation: 12,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(38),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade900.withOpacity(0.13),
                  blurRadius: 18,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(items.length, (index) {
                bool isSelected = currentIndex == index;
                final isNotificationTab = index == 2;

                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => _handleTap(context, index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: EdgeInsets.symmetric(
                        vertical: isSelected ? 2 : 8,
                        horizontal: 2,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: isSelected ? 2 : 8,
                      ),
                      decoration:
                          isSelected
                              ? BoxDecoration(
                                color: Colors.blue[700]!.withOpacity(0.94),
                                borderRadius: BorderRadius.circular(22),
                              )
                              : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isNotificationTab)
                            Obx(() {
                              final unreadCount =
                                  notifController.notifications
                                      .where((n) => !n.isRead)
                                      .length;

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    items[index].icon,
                                    color: Colors.white,
                                    size: isSelected ? 32 : 26,
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          unreadCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            })
                          else
                            Icon(
                              items[index].icon,
                              color: Colors.white,
                              size: isSelected ? 32 : 26,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem {
  final IconData icon;
  final String label;
  _NavBarItem(this.icon, this.label);
}

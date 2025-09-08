import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_home_page.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomNavBar({super.key, this.currentIndex = 0});

  void _onTap(int index) {
    switch (index) {
      case 0:
        Get.offAll(() => const NonEmployeeHomeScreen());
        break;
      case 1:
        Get.snackbar("Coming Soon", "Jobs page is under development");
        break;
      case 2:
        Get.snackbar("Coming Soon", "Notifications page is under development");
        break;
      case 3:
        Get.snackbar("Coming Soon", "Profile page is under development");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: _onTap,
      backgroundColor: Colors.blue,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"),
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          label: "JOBS",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: "NOTIFY",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "PROFILE",
        ),
      ],
    );
  }
}

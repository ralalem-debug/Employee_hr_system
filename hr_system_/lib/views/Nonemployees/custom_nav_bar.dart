import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_home_page.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_profile_screen.dart';

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
        Get.offAll(() => const NonEmployeeProfileScreen());

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: _onTap,
      backgroundColor: Colors.blue[800],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"),
        BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: ""),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "PROFILE",
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/views/Nonemployees/available_assessment_page.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_home_page.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_notifications_screen.dart';
import 'package:hr_system_/views/Nonemployees/settings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomNavBar({super.key, this.currentIndex = 0});

  Future<String?> _getNonEmployeeId() async {
    const storage = FlutterSecureStorage();

    final savedId = await storage.read(key: "user_id");
    if (savedId != null && savedId.isNotEmpty) {
      print("✅ Loaded nonEmployeeId from storage: $savedId");
      return savedId;
    }

    final token = await storage.read(key: "auth_token");
    if (token == null || token.isEmpty) {
      print("⚠️ No token found in storage (key: auth_token)");
      return null;
    }

    try {
      final decoded = JwtDecoder.decode(token);
      print("🟦 Token Claims: $decoded");

      final id =
          decoded["sub"] ??
          decoded["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"];
      print("✅ Extracted NonEmployee ID from token: $id");

      return id?.toString();
    } catch (e) {
      print("❌ Failed to decode token: $e");
      return null;
    }
  }

  void _onTap(int index) async {
    switch (index) {
      case 0:
        Get.offAll(() => const NonEmployeeHomeScreen());
        break;

      case 1:
        final nonEmployeeId = await _getNonEmployeeId();
        if (nonEmployeeId != null) {
          print("🚀 Opening AvailableAssessmentPage for ID: $nonEmployeeId");
          Get.offAll(
            () => AvailableAssessmentPage(nonEmployeeId: nonEmployeeId),
          );
        } else {
          Get.snackbar(
            "Error",
            "Could not load your ID. Please log in again.",
            backgroundColor: Colors.redAccent.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
        break;

      case 2:
        Get.offAll(() => const NotificationsScreen());
        break;

      case 3:
        Get.offAll(() => const SettingsScreen());
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
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          label: "ASSESSMENT",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: "NOTIFICATION",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}

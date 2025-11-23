import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:hr_system_/views/Nonemployees/available_assessment_page.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_home_page.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_notifications_screen.dart';
import 'package:hr_system_/views/Nonemployees/settings.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomNavBar({super.key, this.currentIndex = 0});

  Future<String?> _getNonEmployeeId() async {
    const storage = FlutterSecureStorage();

    final savedId = await storage.read(key: "user_id");
    if (savedId != null && savedId.isNotEmpty) {
      debugPrint("✅ Loaded nonEmployeeId from storage: $savedId");
      return savedId;
    }

    final token = await storage.read(key: "auth_token");
    if (token == null || token.isEmpty) {
      debugPrint("⚠️ No token found in storage (key: auth_token)");
      return null;
    }

    try {
      final decoded = JwtDecoder.decode(token);
      debugPrint("🟦 Token Claims: $decoded");

      final id =
          decoded["sub"] ??
          decoded["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"];
      debugPrint("✅ Extracted NonEmployee ID from token: $id");

      return id?.toString();
    } catch (e) {
      debugPrint("❌ Failed to decode token: $e");
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = screenWidth * 0.065;
    final double fontSize = screenWidth * 0.03;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0), // مسافة صغيرة عن الحواف
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25), // حواف شبه دائرية
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[800],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: _onTap,
              backgroundColor: Colors.transparent, // لأن اللون من الـ Container
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              type: BottomNavigationBarType.fixed,
              iconSize: iconSize.clamp(20, 30),
              selectedLabelStyle: TextStyle(
                fontSize: fontSize.clamp(10, 14),
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(fontSize: fontSize.clamp(9, 13)),
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
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "SETTINGS",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/views/employee_nav_bar.dart';
import '../../../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  SettingsScreen({super.key});
  Future<void> _logout() async {
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => EmployeeNavBar(currentIndex: 0)),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue[700],
          title: const Row(mainAxisAlignment: MainAxisAlignment.center),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _headerCard(), // الهيدر الجديد بدون صورة
            const SizedBox(height: 14),
            _sectionTitle("Account Settings"),
            _settingTile("Edit profile", Icons.person_outline, () {
              Get.toNamed('/profile');
            }),
            // _settingTile("Change password", Icons.lock_outline, () {
            //   _goToChangePassword();
            // }),
            const SizedBox(height: 14),
            _sectionTitle("More"),
            _settingTile("About us", Icons.info_outline, () {
              Get.toNamed('/aboutus');
            }),
            _settingTile("Privacy policy", Icons.privacy_tip_outlined, () {
              Get.toNamed('/privacypolicy');
            }),
            const SizedBox(height: 14),
            _sectionTitle("Account"),
            _settingTile("Logout", Icons.logout, () {
              _logout();
            }),
          ],
        ),
        bottomNavigationBar: const EmployeeNavBar(currentIndex: 4),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, color: Colors.white, size: 40),
          SizedBox(width: 15),
          Text("Settings", style: TextStyle(color: Colors.white, fontSize: 50)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _settingTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[800]),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

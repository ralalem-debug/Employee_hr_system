import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/nonemployee_profile_controller.dart';
import 'package:hr_system_/views/Nonemployees/custom_nav_bar.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_profile_screen.dart';
import 'package:hr_system_/views/after login/change_password_screen.dart';
import 'package:hr_system_/controllers/login_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool showSwitch = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing:
          showSwitch
              ? Switch(value: false, onChanged: (_) {})
              : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.put(ProfileController());
    profileController.fetchProfile();
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Obx(() {
        final profile = profileController.profile.value;

        return Column(
          children: [
            // 🔹 الهيدر الأزرق
            Stack(
              children: [
                // خلفية الهيدر
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 60,
                    horizontal: 20,
                  ),
                ),
              ],
            ),

            // Body
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  children: [
                    // اسم المستخدم وإيميله
                    ListTile(
                      title: Text(
                        profile?.fullNameE ?? "Loading...",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(profile?.email ?? "Loading..."),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ),

                    const Divider(),

                    // Account Settings
                    _buildSectionTitle("Account Settings"),
                    _buildListTile(
                      title: "My information",
                      icon: Icons.info_outline,
                      onTap: () {
                        Get.to(() => const NonEmployeeProfileScreen());
                      },
                    ),
                    _buildListTile(
                      title: "Change password",
                      icon: Icons.lock_outline,
                      onTap: () {
                        Get.to(
                          () => ChangePasswordScreen(
                            token: "", // مرر التوكن من الكنترولر
                            isFirstLogin: false,
                          ),
                        );
                      },
                    ),

                    const Divider(),

                    // More
                    _buildSectionTitle("More"),
                    _buildListTile(
                      title: "About us",
                      icon: Icons.info,
                      onTap: () {},
                    ),
                    _buildListTile(
                      title: "Privacy policy",
                      icon: Icons.privacy_tip_outlined,
                      onTap: () {},
                    ),
                    _buildListTile(
                      title: "Terms and conditions",
                      icon: Icons.description_outlined,
                      onTap: () {},
                    ),
                    _buildListTile(
                      title: "Need Help ?",
                      icon: Icons.help_outline,
                      onTap: () {},
                    ),

                    const Divider(),

                    // Logout
                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final loginController = Get.put(LoginController());
                          loginController.logout();
                          Get.offAllNamed("/login");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: const CustomNavBar(currentIndex: 3), // ✅ Tab notify
    );
  }
}

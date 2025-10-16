import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/nonemployee_profile_controller.dart';
import 'package:hr_system_/views/Nonemployees/custom_nav_bar.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_profile_screen.dart';
import 'package:hr_system_/views/after login/change_password_screen.dart';
import 'package:hr_system_/controllers/login_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildSectionTitle(String title, double width) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: width * 0.04),
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
    double width = 0,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue, size: width * 0.06),
      title: Text(title, style: TextStyle(fontSize: width * 0.04)),
      trailing:
          showSwitch
              ? Switch(value: false, onChanged: (_) {})
              : Icon(Icons.arrow_forward_ios, size: width * 0.04),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final profileController = Get.put(ProfileController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (profileController.profile.value == null) {
        profileController.fetchProfile();
      }
    });

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // 🔹 أزلنا الخلفية الزرقاء
        body: Obx(() {
          final profile = profileController.profile.value;

          return Column(
            children: [
              // رأس الصفحة فقط أزرق
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.05,
                  horizontal: size.width * 0.05,
                ),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 8, 112, 197),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
              ),

              // باقي الصفحة أبيض
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: ListView(
                    children: [
                      ListTile(
                        title: Text(
                          profile?.fullNameE ?? "Loading...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.045,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          profile?.email ?? "Loading...",
                          style: TextStyle(fontSize: size.width * 0.035),
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: CircleAvatar(
                          radius: size.width * 0.07,
                          backgroundColor: const Color.fromARGB(
                            255,
                            7,
                            99,
                            173,
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: size.width * 0.07,
                          ),
                        ),
                      ),

                      const Divider(),

                      // Account Settings
                      _buildSectionTitle("Account Settings", size.width),
                      _buildListTile(
                        title: "My information",
                        icon: Icons.info_outline,
                        onTap: () {
                          Get.to(() => const NonEmployeeProfileScreen());
                        },
                        width: size.width,
                      ),
                      _buildListTile(
                        title: "Change password",
                        icon: Icons.lock_outline,
                        onTap: () {
                          Get.to(
                            () => ChangePasswordScreen(
                              token: "",
                              isFirstLogin: false,
                            ),
                          );
                        },
                        width: size.width,
                      ),

                      const Divider(),

                      // More
                      _buildSectionTitle("More", size.width),
                      _buildListTile(
                        title: "About us",
                        icon: Icons.info,
                        onTap: () {
                          Get.toNamed('/aboutus');
                        },
                        width: size.width,
                      ),
                      _buildListTile(
                        title: "Privacy policy",
                        icon: Icons.privacy_tip_outlined,
                        onTap: () {
                          Get.toNamed('/privacypolicy');
                        },
                        width: size.width,
                      ),
                      _buildListTile(
                        title: "Terms and conditions",
                        icon: Icons.description_outlined,
                        onTap: () {},
                        width: size.width,
                      ),
                      _buildListTile(
                        title: "Need Help ?",
                        icon: Icons.help_outline,
                        onTap: () {},
                        width: size.width,
                      ),

                      const Divider(),

                      SizedBox(height: size.height * 0.02),

                      // Logout
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final loginController = Get.put(LoginController());
                            loginController.logout();
                            Get.offAllNamed("/login");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade100,
                            foregroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.018,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.logout, size: size.width * 0.06),
                          label: Text(
                            "Logout",
                            style: TextStyle(fontSize: size.width * 0.045),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
        bottomNavigationBar: const CustomNavBar(currentIndex: 3),
      ),
    );
  }
}

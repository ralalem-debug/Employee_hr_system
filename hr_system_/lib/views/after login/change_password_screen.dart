import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/views/after login/take_selfie.dart';
import 'package:hr_system_/views/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/change_password_controller.dart';

class ChangePasswordScreen extends StatelessWidget {
  final String token;
  final bool isFirstLogin; // ⬅️ نستقبلها من LoginController

  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  ChangePasswordScreen({
    super.key,
    required this.token,
    required this.isFirstLogin,
  });

  final ChangePasswordController controller = Get.put(
    ChangePasswordController(),
  );

  Future<void> _handleChange() async {
    if (_newPassController.text.trim().isEmpty ||
        _confirmPassController.text.trim().isEmpty) {
      Get.snackbar('Error', "Please fill all fields.");
      return;
    }
    if (_newPassController.text != _confirmPassController.text) {
      Get.snackbar('Error', "Passwords do not match.");
      return;
    }

    final success = await controller.changePassword(
      _newPassController.text.trim(),
      _confirmPassController.text.trim(),
    );

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('selfie_done', false);
      await prefs.setBool('signature_done', false);
      await prefs.setString('token', token);

      // ✅ Navigation logic based on isFirstLogin
      if (isFirstLogin) {
        Get.offAll(() => TakeSelfiePage(token: token));
      } else {
        Get.offAll(() => const HomeScreen());
      }
    } else {
      Get.snackbar(
        'Error',
        controller.errorMessage ?? "Failed to change password.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('images/bg_pattern.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 40,
                        ),
                        child: Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('images/login_logo.png', height: 200),
                              const SizedBox(height: 50),
                              const Text(
                                "Change Password",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 30),
                              TextField(
                                controller: _newPassController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: "New Password",
                                  prefixIcon: Icon(Icons.lock),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _confirmPassController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: "Confirm Password",
                                  prefixIcon: Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      controller.isLoading.value
                                          ? null
                                          : _handleChange,
                                  child:
                                      controller.isLoading.value
                                          ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : const Text("Confirm"),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

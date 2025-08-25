import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/reset_password_controller.dart';
import 'password_success_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String token;
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final ResetPasswordController controller = Get.put(ResetPasswordController());

  ResetPasswordScreen({super.key, required this.token});

  Future<void> _resetPass() async {
    if (_newPassController.text.trim().isEmpty ||
        _confirmPassController.text.trim().isEmpty) {
      Get.snackbar('Error', "Please fill all fields.");
      return;
    }
    if (_newPassController.text != _confirmPassController.text) {
      Get.snackbar('Error', "Passwords do not match.");
      return;
    }

    final success = await controller.resetPassword(
      token,
      _newPassController.text.trim(),
      _confirmPassController.text.trim(),
    );

    if (success) {
      Get.offAll(() => PasswordSuccessScreen());
    } else {
      Get.snackbar(
        'Error',
        controller.errorMessage ?? "Failed to reset password.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.90,
              child: Image.asset('images/bg_pattern.png', fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 60,
                ),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('images/login_logo.png', height: 200),
                      const SizedBox(height: 50),
                      const Text(
                        "Reset Password",
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
                              controller.isLoading.value ? null : _resetPass,
                          child:
                              controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text("Confirm"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

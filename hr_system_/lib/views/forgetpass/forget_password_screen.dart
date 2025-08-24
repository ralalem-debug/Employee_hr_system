import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/forget_password_controller.dart';
import 'verify_code_screen.dart';

class ForgetPasswordScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final ForgetPasswordController controller = Get.put(
    ForgetPasswordController(),
  );

  ForgetPasswordScreen({super.key});

  Future<void> _sendCode() async {
    final success = await controller.sendCode(_emailController.text.trim());
    if (success) {
      Get.off(() => VerifyCodeScreen(email: _emailController.text.trim()));
    } else {
      Get.snackbar('Error', controller.errorMessage ?? "Something went wrong");
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
                  vertical: 200,
                ),
                child: Obx(
                  () => Column(
                    children: [
                      Image.asset('images/login_logo.png', height: 180),
                      const SizedBox(height: 10),
                      const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              controller.isLoading.value ? null : _sendCode,
                          child:
                              controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text("Send Code"),
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

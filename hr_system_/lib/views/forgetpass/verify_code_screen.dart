import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/verify_code_controller.dart';
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatelessWidget {
  final String email;
  final _codeController = TextEditingController();
  final VerifyCodeController controller = Get.put(VerifyCodeController());

  VerifyCodeScreen({super.key, required this.email});

  Future<void> _verifyAndGo() async {
    final success = await controller.verifyCode(_codeController.text.trim());
    if (success && controller.token != null) {
      Get.off(() => ResetPasswordScreen(token: controller.token!));
    } else {
      Get.snackbar('Error', controller.errorMessage ?? "Wrong code.");
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
                      Image.asset('images/login_logo.png', height: 160),
                      const SizedBox(height: 18),
                      const Text(
                        "Enter Verification Code",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: "Verification Code",
                          prefixIcon: Icon(Icons.verified_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              controller.isLoading.value ? null : _verifyAndGo,
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

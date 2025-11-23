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
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          /// خلفية خفيفة
          Positioned.fill(
            child: Opacity(
              opacity: 0.9,
              child: Image.asset('images/bg_pattern.png', fit: BoxFit.cover),
            ),
          ),

          /// المحتوى الأساسي
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// الشعار
                      Image.asset(
                        'images/login_logo.png',
                        height: height * 0.18,
                      ),

                      const SizedBox(height: 30),

                      /// العنوان
                      const Text(
                        "Enter Verification Code",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// حقل الكود
                      TextField(
                        controller: _codeController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Verification Code",
                          labelStyle: const TextStyle(fontSize: 16),
                          prefixIcon: const Icon(Icons.verified_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      /// زر التأكيد
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0xFF007BFF),
                          ),
                          onPressed:
                              controller.isLoading.value ? null : _verifyAndGo,
                          child:
                              controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    "Confirm",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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

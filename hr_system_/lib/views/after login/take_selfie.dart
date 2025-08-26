import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../controllers/selfie_controller.dart';
import 'signature_screen.dart';

class TakeSelfiePage extends StatefulWidget {
  const TakeSelfiePage({Key? key}) : super(key: key);

  @override
  State<TakeSelfiePage> createState() => _TakeSelfiePageState();
}

class _TakeSelfiePageState extends State<TakeSelfiePage> {
  File? _selfie;
  final controller = Get.put(SelfieController());

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _selfie = File(picked.path));
  }

  Future<void> _submit() async {
    if (_selfie == null) {
      Get.snackbar("Error", "Please take a selfie first");
      return;
    }

    // ✅ جلب التوكن من التخزين
    final token = await storage.read(key: 'auth_token') ?? '';
    if (token.isEmpty) {
      Get.snackbar("Error", "Missing token. Please login again.");
      return;
    }

    bool success = await controller.uploadSelfie(_selfie!, token);

    if (success) {
      Get.offAll(() => const SignatureScreen());
    } else {
      Get.snackbar("Error", controller.errorMessage ?? "Failed to upload");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Create Profile',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome, Employee 👋',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                // Warning message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow.shade700),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: 26,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Please complete your profile to access the system.',
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Clear selfie instructions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Please take a clear selfie:\n\n'
                    '1. Make sure your full face is visible.\n'
                    '2. Look directly at the camera.\n'
                    '3. No glasses or hats.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueAccent,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 14),

                // Selfie button
                InkWell(
                  onTap: controller.isLoading.value ? null : _pickImage,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.blueAccent, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue[700]!,
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child:
                        _selfie != null
                            ? ClipOval(
                              child: Image.file(
                                _selfie!,
                                width: 170,
                                height: 170,
                                fit: BoxFit.cover,
                              ),
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.camera_alt_rounded,
                                  size: 52,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Take Selfie',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),

                const SizedBox(height: 24),

                controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: controller.isLoading.value ? null : _submit,
                      child: const Text("Continue"),
                    ),

                const SizedBox(height: 28),
                const Text(
                  'Your photo will not be shared with any external parties.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

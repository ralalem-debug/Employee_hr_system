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
  File? _frontSelfie;
  File? _leftSelfie;
  File? _rightSelfie;

  final controller = Get.put(SelfieController());
  final storage = const FlutterSecureStorage();

  Future<void> _pickImage(String type) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        if (type == "front") _frontSelfie = File(picked.path);
        if (type == "left") _leftSelfie = File(picked.path);
        if (type == "right") _rightSelfie = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_frontSelfie == null || _leftSelfie == null || _rightSelfie == null) {
      Get.snackbar("Error", "Please take all 3 selfies first");
      return;
    }

    final token = await storage.read(key: 'auth_token') ?? '';
    if (token.isEmpty) {
      Get.snackbar("Error", "Missing token. Please login again.");
      return;
    }

    bool success = await controller.uploadSelfies([
      _frontSelfie!,
      _leftSelfie!,
      _rightSelfie!,
    ], token);

    if (success) {
      Get.offAll(() => const SignatureScreen());
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

                // Warning
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

                // General instructions
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
                    'Selfie Instructions:\n\n'
                    '1. Take 3 photos (Front, Left, Right).\n'
                    '2. Make sure your full face is visible.\n'
                    '3. Look directly at the camera.\n'
                    '4. No glasses or hats.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueAccent,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 14),

                // Front Selfie
                _buildSelfieSection(
                  label: "Front Selfie",
                  description: "Face directly to the camera.",
                  file: _frontSelfie,
                  onTap: () => _pickImage("front"),
                ),

                const SizedBox(height: 20),

                // Left Selfie
                _buildSelfieSection(
                  label: "Left Side Selfie",
                  description: "Turn your head to the left.",
                  file: _leftSelfie,
                  onTap: () => _pickImage("left"),
                ),

                const SizedBox(height: 20),

                // Right Selfie
                _buildSelfieSection(
                  label: "Right Side Selfie",
                  description: "Turn your head to the right.",
                  file: _rightSelfie,
                  onTap: () => _pickImage("right"),
                ),

                const SizedBox(height: 30),

                controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: controller.isLoading.value ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                const SizedBox(height: 28),
                const Text(
                  'Your photos will not be shared with any external parties.',
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

  Widget _buildSelfieSection({
    required String label,
    required String description,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: controller.isLoading.value ? null : onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child:
                file != null
                    ? ClipOval(child: Image.file(file, fit: BoxFit.cover))
                    : const Center(
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 50,
                        color: Colors.blueAccent,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}

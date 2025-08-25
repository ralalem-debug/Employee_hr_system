import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/selfie_controller.dart';
import 'signature_screen.dart';

class TakeSelfiePage extends StatefulWidget {
  final String token;

  const TakeSelfiePage({Key? key, required this.token}) : super(key: key);

  @override
  State<TakeSelfiePage> createState() => _TakeSelfiePageState();
}

class _TakeSelfiePageState extends State<TakeSelfiePage> {
  File? _selfie;
  final controller = Get.put(SelfieController());

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

    bool success = await controller.uploadSelfie(_selfie!, widget.token);

    if (success) {
      // ✅ بعد السيلفي → على صفحة التوقيع
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Welcome, Employee 👋',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

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
                    ),
                    child:
                        _selfie != null
                            ? ClipOval(
                              child: Image.file(_selfie!, fit: BoxFit.cover),
                            )
                            : const Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.blueAccent,
                            ),
                  ),
                ),

                const SizedBox(height: 24),

                controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Continue"),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

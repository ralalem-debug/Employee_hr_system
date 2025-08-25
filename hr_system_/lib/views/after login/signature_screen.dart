import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import '../../controllers/signature_controller.dart';
import '../home_screen.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({Key? key}) : super(key: key);

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _sigCtrl = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.blue,
  );
  final SignatureUploadController _controller = Get.put(
    SignatureUploadController(),
  );

  Future<File> _bytesToFile(Uint8List data) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/signature.png');
    await file.writeAsBytes(data);
    return file;
  }

  Future<void> _submitSignature() async {
    if (_sigCtrl.isEmpty) {
      Get.snackbar("Error", "Please sign first");
      return;
    }

    final data = await _sigCtrl.toPngBytes();
    if (data == null) return;
    final file = await _bytesToFile(data);

    bool success = await _controller.uploadSignature(file, "employee");
    if (success) {
      // ✅ بعد التوقيع → على الهوم
      Get.offAll(() => const HomeScreen());
    } else {
      Get.snackbar("Error", _controller.errorMessage ?? "Failed to upload");
    }
  }

  @override
  void dispose() {
    _sigCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Signature")),
      body: Obx(
        () => Center(
          child:
              _controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Signature(
                        controller: _sigCtrl,
                        height: 200,
                        backgroundColor: Colors.grey[200]!,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitSignature,
                        child: const Text("Done"),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

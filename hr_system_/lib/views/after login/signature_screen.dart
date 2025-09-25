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

    bool success = await _controller.uploadSignature(file);
    if (success) {
      Get.snackbar("Success", "Signature uploaded successfully ✅");
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Your Signature'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Obx(
        () =>
            _controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome, Employee",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // صندوق التوقيع
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Signature(
                          controller: _sigCtrl,
                          height: 200,
                          backgroundColor: Colors.grey[200]!,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // الأزرار
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () => _sigCtrl.clear(),
                            child: const Text("Clear"),
                          ),
                          const SizedBox(width: 18),
                          ElevatedButton(
                            onPressed: _submitSignature,
                            child: const Text("Done"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ملاحظة
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                          horizontal: 15,
                        ),
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.yellow[50],
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: Colors.amber.shade700,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.amber,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Please note:\n"
                                "Your signature will be securely stored and used by the company "
                                "for all official internal approvals and processes. "
                                "Make sure your signature is clear and represents your authorization. "
                                "If you have any concerns, please contact HR before submitting.",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      ),
    );
  }
}

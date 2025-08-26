import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/profile_controller.dart';

class EditDocumentsScreen extends StatelessWidget {
  final ProfileController controller;
  const EditDocumentsScreen({required this.controller, Key? key})
    : super(key: key);

  Future<void> _pickAndUpload(
    BuildContext context,
    String fieldName,
    ProfileController c,
  ) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      bool ok = await c.uploadDocument(fieldName, file);
      if (ok) {
        await c.fetchProfile(); // ✅ جلب جديد بعد الرفع
        Get.snackbar("Success", "$fieldName uploaded successfully");
      } else {
        Get.snackbar("Error", "Failed to upload $fieldName");
      }
    }
  }

  Future<void> _downloadFile(String type, String extension, String url) async {
    final ok = await controller.downloadDocument(
      type,
      extension,
      directUrl: url, // مرر الرابط المباشر
    );
    if (!ok) {
      Get.snackbar("Error", "Download failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Documents",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),

      body: Obx(() {
        final docs = controller.documents.value;
        if (docs == null) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            _docTile("CV", docs.cv, "cv", "pdf"),
            _docTile(
              "University Certificate",
              docs.universityCertificate,
              "universitycertificate",
              "pdf",
            ),
            _docTile("Contract", docs.contract, "contract", "pdf"),
            _docTile(
              "National Identity",
              docs.nationalIdentity,
              "nationalidentity",
              "jpg",
            ),
            _docTile("Passport", docs.passport, "passport", "jpg"),
            _docTile("Signature", docs.signature, "signature", "jpg"),
            _docTile("Other", docs.other, "other", "pdf"),
          ],
        );
      }),
    );
  }

  Widget _docTile(String title, String url, String type, String extension) {
    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(title),
        subtitle:
            url.isEmpty
                ? Text("No file")
                : Text(url.split('/').last), // ✅ عرض اسم الملف فقط
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.download),
              onPressed:
                  url.isEmpty
                      ? null // ✅ عطّل زر التحميل إذا ما في ملف
                      : () => _downloadFile(type, extension, url),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.upload_file),
          onPressed:
              () => _pickAndUpload(
                Get.context!, // أو مرر context من build لو بدك أأمن
                type,
                controller,
              ),
        ),
      ),
    );
  }
}

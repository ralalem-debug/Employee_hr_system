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
        await c.fetchProfile(); // ✅ تحديث البيانات
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
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Obx(() {
        final docs = controller.documents.value;
        if (docs == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _docTile("CV", docs.cv, "cv", "pdf", context),
            _docTile(
              "University Certificate",
              docs.universityCertificate,
              "universitycertificate",
              "pdf",
              context,
            ),
            _docTile("Contract", docs.contract, "contract", "pdf", context),
            _docTile(
              "National Identity",
              docs.nationalIdentity,
              "nationalidentity",
              "pdf",
              context,
            ),
            _docTile("Passport", docs.passport, "passport", "pdf", context),
            _docTile("Signature", docs.signature, "signature", "pdf", context),
            _docTile("Other", docs.other, "other", "pdf", context),
          ],
        );
      }),
    );
  }

  Widget _docTile(
    String title,
    String url,
    String type,
    String extension,
    BuildContext context,
  ) {
    final fileName =
        url.isEmpty ? "No file" : url.split('/').last; // ✅ عرض اسم الملف فقط

    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(title),
        subtitle: Text(fileName),
        leading: IconButton(
          icon: const Icon(Icons.download),
          onPressed:
              url.isEmpty ? null : () => _downloadFile(type, extension, url),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.upload_file),
          onPressed: () => _pickAndUpload(context, type, controller),
        ),
      ),
    );
  }
}

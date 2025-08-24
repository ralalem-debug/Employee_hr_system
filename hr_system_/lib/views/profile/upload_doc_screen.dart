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
            _docTile("CV", docs.cvUrl, "cvUrl", "pdf"),
            _docTile(
              "University Certificate",
              docs.universityCertificateUrl,
              "universityCertificateUrl",
              "pdf",
            ),
            _docTile("Contract", docs.contractUrl, "contractUrl", "pdf"),
            _docTile(
              "National Identity",
              docs.nationalIdentity,
              "nationalIdentity",
              "jpg",
            ),
            _docTile("Passport", docs.passport, "passport", "jpg"),
          ],
        );
      }),
    );
  }

  Widget _docTile(String title, String url, String type, String extension) {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: ListTile(
        title: Text(title),
        subtitle: url.isEmpty ? Text("No file") : Text(url),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.download),
              onPressed: () => _downloadFile(type, extension, url),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.upload_file),
          onPressed:
              () =>
                  _pickAndUpload(Get.context!, type, controller), // ✅ رفع جديد
        ),
      ),
    );
  }
}

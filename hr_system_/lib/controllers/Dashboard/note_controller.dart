import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_system_/app_config.dart';
import '../../models/Dashboard/note_model.dart';

class NoteController extends GetxController {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  var isSent = false.obs;
  var isLoading = false.obs;
  var error = RxnString();

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  String get _apiUrl => '${AppConfig.baseUrl}/notes/send-note';

  // Send note to API
  Future<void> sendNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      error.value = "Please fill in all fields.";
      return;
    }

    isLoading.value = true;
    error.value = null;

    final token = await storage.read(key: 'auth_token') ?? '';

    final note = NoteModel(title: title, content: content);

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(note.toJson()),
      );

      if (response.statusCode == 200) {
        isSent.value = true;
        error.value = null;
        titleController.clear();
        contentController.clear();
      } else {
        error.value = "Error sending note: ${response.body}";
      }
    } catch (e) {
      error.value = "Connection error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void resetStatus() {
    isSent.value = false;
    error.value = null;
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/models/Dashboard/list_note_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotesListController extends GetxController {
  var notes = <ListNoteModel>[].obs;
  var isLoading = false.obs;
  var error = RxnString();

  static const String getUrl =
      'http://192.168.1.131:5005/api/notes/Employee-notes';
  static const String deleteUrl = 'http://192.168.1.131:5005/api/notes/delete/';

  // Fetch notes from API
  Future<void> fetchNotes() async {
    isLoading.value = true;
    error.value = null;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    try {
      final response = await http.get(
        Uri.parse(getUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        notes.value = data.map((e) => ListNoteModel.fromJson(e)).toList();
      } else {
        error.value = "Error fetching notes: ${response.body}";
      }
    } catch (e) {
      error.value = "Connection error: $e";
    }
    isLoading.value = false;
  }

  // Delete note from API
  Future<void> deleteNote(String noteId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    try {
      final response = await http.delete(
        Uri.parse('$deleteUrl$noteId'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        notes.removeWhere((note) => note.noteId == noteId);
        Get.snackbar(
          "Deleted",
          "Note deleted successfully",
          backgroundColor: Colors.green.shade50,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to delete note",
          backgroundColor: Colors.red.shade50,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Connection problem",
        backgroundColor: Colors.red.shade50,
      );
    }
  }
}

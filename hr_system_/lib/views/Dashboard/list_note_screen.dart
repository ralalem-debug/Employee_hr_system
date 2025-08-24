import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/Dashboard/list_note_controller.dart';
import 'note_screen.dart';
import '../employee_nav_bar.dart';

class NotesListScreen extends StatelessWidget {
  NotesListScreen({Key? key}) : super(key: key);

  final NotesListController controller = Get.put(NotesListController());

  @override
  Widget build(BuildContext context) {
    controller.fetchNotes();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Notes",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value != null) {
          return Center(
            child: Text(
              controller.error.value!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (controller.notes.isEmpty) {
          return const Center(
            child: Text("No notes found.", style: TextStyle(fontSize: 16)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          itemCount: controller.notes.length,
          itemBuilder: (context, index) {
            final note = controller.notes[index];
            return Card(
              color: const Color.fromARGB(255, 255, 255, 255),
              margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                title: Text(
                  note.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.date,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                            title: const Text('Delete Confirmation'),
                            content: const Text(
                              'Are you sure you want to delete this note?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                    );
                    if (confirmed == true) {
                      await controller.deleteNote(note.noteId);
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: Colors.blue.shade800,
        onPressed: () async {
          // Open add note page, then refresh the list if a note was added
          await Get.to(() => NoteScreen());
          await controller.fetchNotes();
        },
      ),
      bottomNavigationBar: EmployeeNavBar(currentIndex: 1),
    );
  }
}

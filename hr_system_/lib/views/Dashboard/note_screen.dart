import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Dashboard/note_controller.dart';
import '../employee_nav_bar.dart';

class NoteScreen extends StatelessWidget {
  NoteScreen({Key? key}) : super(key: key);

  final NoteController controller = Get.put(NoteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  "Send Note",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Card(
                color: const Color.fromARGB(255, 255, 255, 255),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 28,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 370),
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Note Title",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller.titleController,
                            decoration: InputDecoration(
                              hintText: "Enter title...",
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "Note Content",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller.contentController,
                            minLines: 3,
                            maxLines: 6,
                            decoration: InputDecoration(
                              hintText: "Enter your note...",
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 24),
                          controller.isLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton.icon(
                                onPressed:
                                    controller.isSent.value
                                        ? null
                                        : () async {
                                          await controller.sendNote();
                                        },
                                icon: const Icon(Icons.send_rounded, size: 22),
                                label: const Text(
                                  "Send Note",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                          const SizedBox(height: 20),
                          if (controller.error.value != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                controller.error.value!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (controller.isSent.value)
                            Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 26,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Your note has been successfully sent and is under review.",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: EmployeeNavBar(currentIndex: 2),
    );
  }
}

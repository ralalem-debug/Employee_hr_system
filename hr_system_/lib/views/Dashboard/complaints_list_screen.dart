import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Dashboard/complaints_list_controller.dart';
import 'complaint_screen.dart';
import '../employee_nav_bar.dart';

class ComplaintsListScreen extends StatelessWidget {
  ComplaintsListScreen({Key? key}) : super(key: key);

  final ComplaintsListController controller = Get.put(
    ComplaintsListController(),
  );

  @override
  Widget build(BuildContext context) {
    controller.fetchComplaints();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Complaints",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
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
        if (controller.complaints.isEmpty) {
          return const Center(
            child: Text("No complaints found.", style: TextStyle(fontSize: 16)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          itemCount: controller.complaints.length,
          itemBuilder: (context, index) {
            final complaint = controller.complaints[index];
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
                  complaint.subject,
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
                      complaint.details,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    if (complaint.date != null)
                      Text(
                        complaint.date!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    if (complaint.complaintAgainstEmployee != null)
                      Text(
                        "Against: ${complaint.complaintAgainstEmployee}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey,
                        ),
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
                            title: const Text('Delete Confirmation'),
                            content: const Text(
                              'Are you sure you want to delete this complaint?',
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
                      await controller.deleteComplaint(complaint.complaintId!);
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
          await Get.to(() => ComplaintScreen());
          await controller.fetchComplaints();
        },
      ),
      bottomNavigationBar: EmployeeNavBar(currentIndex: 1),
    );
  }
}

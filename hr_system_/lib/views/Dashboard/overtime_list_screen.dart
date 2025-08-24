// views/overtime_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/views/Dashboard/overtime_screen.dart';
import '../../controllers/Dashboard/overtime_list_controller.dart';
import '../employee_nav_bar.dart';

class OvertimeListScreen extends StatelessWidget {
  OvertimeListScreen({Key? key}) : super(key: key);

  final OvertimeListController controller = Get.put(OvertimeListController());

  @override
  Widget build(BuildContext context) {
    controller.fetchRequests();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),

        title: const Text(
          "Overtime Requests",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
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
        if (controller.overtimeRequests.isEmpty) {
          return const Center(
            child: Text(
              "No overtime requests found.",
              style: TextStyle(fontSize: 16),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          itemCount: controller.overtimeRequests.length,
          itemBuilder: (context, index) {
            final request = controller.overtimeRequests[index];
            Color statusColor;
            IconData statusIcon;
            switch (request.status) {
              case "Approved":
                statusColor = Colors.green;
                statusIcon = Icons.check_circle_outline;
                break;
              case "Rejected":
                statusColor = Colors.red;
                statusIcon = Icons.cancel_outlined;
                break;
              default:
                statusColor = Colors.orange;
                statusIcon = Icons.access_time;
            }
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
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.task,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    Icon(statusIcon, color: statusColor),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text("Date: ${request.date}"),
                    Text("From: ${request.fromTime} - To: ${request.toTime}"),
                    Text("Hours: ${request.hours}"),
                    Text(request.isHoliday ? "On Holiday" : "Normal Day"),
                    const SizedBox(height: 8),
                    Text(
                      request.status ?? "",
                      style: TextStyle(
                        fontSize: 13,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
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
                            backgroundColor: Colors.white,
                            title: const Text('Delete Confirmation'),
                            content: const Text(
                              'Are you sure you want to delete this request?',
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
                    if (confirmed == true && request.overtimeId != null) {
                      await controller.deleteRequest(request.overtimeId!);
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
        label: const Text("Add", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade800,
        onPressed: () async {
          await Get.to(() => OvertimeRequestScreen());
          await controller.fetchRequests();
        },
      ),
      bottomNavigationBar: EmployeeNavBar(currentIndex: 1),
    );
  }
}

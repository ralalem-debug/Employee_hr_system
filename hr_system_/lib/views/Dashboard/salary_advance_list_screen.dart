import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Dashboard/salary_advance_list_controller.dart';
import 'salary_advance_screen.dart';
import '../employee_nav_bar.dart';

class SalaryAdvanceListScreen extends StatelessWidget {
  SalaryAdvanceListScreen({Key? key}) : super(key: key);

  final SalaryAdvanceListController controller = Get.put(
    SalaryAdvanceListController(),
  );

  @override
  Widget build(BuildContext context) {
    controller.fetchRequests();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Salary Advance Requests",
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
        if (controller.requests.isEmpty) {
          return const Center(
            child: Text("No requests found.", style: TextStyle(fontSize: 16)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          itemCount: controller.requests.length,
          itemBuilder: (context, index) {
            final request = controller.requests[index];
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
                  "Amount: ${request.amount}",
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
                      "Deduct from month: ${request.deductFromMonth}",
                      style: const TextStyle(fontSize: 15),
                    ),
                    if (request.requestDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Date: ${request.requestDate}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    if (request.status != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Status: ${request.status}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                          ),
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
                    if (confirmed == true) {
                      await controller.deleteRequest(
                        request.salaryAdvanceRequestId!,
                      );
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
          await Get.to(() => SalaryAdvanceScreen());
          await controller.fetchRequests();
        },
      ),
      bottomNavigationBar: EmployeeNavBar(currentIndex: 1),
    );
  }
}

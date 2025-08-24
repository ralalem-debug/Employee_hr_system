// views/resignation_request_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Dashboard/resignation_request_controller.dart';

class ResignationRequestScreen extends StatelessWidget {
  ResignationRequestScreen({Key? key}) : super(key: key);

  final ResignationRequestController controller = Get.put(
    ResignationRequestController(),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          title: const Text(
            "Resignation Request",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white.withOpacity(0.93),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white,
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
                          "Last Working Day",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.lastWorkingDayController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "YYYY-MM-DD",
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
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          style: const TextStyle(fontSize: 15),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (pickedDate != null) {
                              controller.lastWorkingDayController.text =
                                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "Note (optional)",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.noteController,
                          minLines: 2,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: "Write a note (optional)...",
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
                        const SizedBox(height: 24),
                        controller.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton.icon(
                              onPressed:
                                  controller.isSent.value
                                      ? null
                                      : () async {
                                        await controller.sendResignation();
                                      },
                              icon: const Icon(Icons.send_rounded, size: 22),
                              label: const Text(
                                "Submit Request",
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
                                    "Resignation request submitted.",
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
          ),
        ),
      ),
    );
  }
}

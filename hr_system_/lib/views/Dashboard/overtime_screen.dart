// views/overtime_request_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Dashboard/overtime_controller.dart';

class OvertimeRequestScreen extends StatelessWidget {
  OvertimeRequestScreen({Key? key}) : super(key: key);

  final OvertimeController controller = Get.put(OvertimeController());

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
                  "Overtime Request",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Card(
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
                          // Replace the old "Date" TextField with this code:
                          const Text(
                            "Date",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller.dateController,
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
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                controller.dateController.text =
                                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              }
                            },
                          ),

                          const SizedBox(height: 8),
                          TextField(
                            controller: controller.taskController,
                            decoration: InputDecoration(
                              hintText: "Enter the task...",
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
                            "From Time",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller.fromTimeController,
                            decoration: InputDecoration(
                              hintText: "e.g. 17:00:00",
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
                            "To Time",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller.toTimeController,
                            decoration: InputDecoration(
                              hintText: "e.g. 19:00:00",
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
                            "Hours",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller.hoursController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "e.g. 2",
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
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Obx(
                                () => Checkbox(
                                  value: controller.isHoliday.value,
                                  onChanged: (val) {
                                    controller.isHoliday.value = val ?? false;
                                  },
                                ),
                              ),
                              const Text("Is it a holiday?"),
                            ],
                          ),
                          const SizedBox(height: 24),
                          controller.isLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton.icon(
                                onPressed:
                                    controller.isSent.value
                                        ? null
                                        : () async {
                                          await controller.sendOvertime();
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
                                      "Request submitted successfully.",
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
    );
  }
}

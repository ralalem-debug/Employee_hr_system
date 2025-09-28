import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/evaluation/evaluation_controller.dart';
import 'package:hr_system_/models/evaluation/evaluation_question.dart';

class CoordinatorEvaluationPage extends StatelessWidget {
  const CoordinatorEvaluationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CoordinatorEvaluationController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),

        iconTheme: const IconThemeData(
          color: Colors.black, // لون أيقونة الباك
        ),
      ),
      body: Obx(() {
        if (controller.employees.isEmpty) {
          return const Center(
            child: Text("No employees available for evaluation."),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.employees.length,
          itemBuilder: (context, index) {
            final emp = controller.employees[index];
            return Card(
              color: const Color.fromARGB(255, 255, 255, 255),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  emp.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text("ID: ${emp.id}"),
                children: [
                  Obx(() {
                    final questions =
                        controller.employeeQuestions[emp.id] ?? [];
                    return Column(
                      children: [
                        ...questions.asMap().entries.map((entry) {
                          final qIndex = entry.key;
                          final EvaluationQuestion q = entry.value;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q.section,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  q.question,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: List.generate(5, (score) {
                                    return IconButton(
                                      icon: Icon(
                                        Icons.star,
                                        color:
                                            (q.score ?? 0) > score
                                                ? Colors.amber
                                                : Colors.grey.shade300,
                                      ),
                                      onPressed: () {
                                        controller.setScoreForEmployee(
                                          emp.id,
                                          qIndex,
                                          score + 1,
                                        );
                                      },
                                    );
                                  }),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            controller.submitEvaluationForEmployee(emp.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Submit ",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    );
                  }),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

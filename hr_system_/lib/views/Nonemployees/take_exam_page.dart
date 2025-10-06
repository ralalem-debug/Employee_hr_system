import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_system_/controllers/exam_controller.dart';

class TakeExamPage extends StatefulWidget {
  final String jobId;
  const TakeExamPage({super.key, required this.jobId});

  @override
  State<TakeExamPage> createState() => _TakeExamPageState();
}

class _TakeExamPageState extends State<TakeExamPage> {
  final controller = Get.put(ExamController());
  final storage = const FlutterSecureStorage();

  String? nonEmployeeId;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchExamByJobId(widget.jobId);
    });
  }

  /// 🔹 تحميل الـ nonEmployeeId من التخزين الآمن
  Future<void> _loadUserId() async {
    final id = await storage.read(key: "user_id");
    setState(() {
      nonEmployeeId = id;
    });
    print("🟢 Loaded NonEmployeeId: $nonEmployeeId");
  }

  int _calculateScore() {
    final exam = controller.selectedExam.value;
    if (exam == null) return 0;

    int score = 0;
    for (var q in exam.mcqs) {
      if (q.selectedAnswer == q.correctAnswer) {
        score++;
      }
    }
    return score;
  }

  Future<void> _submitExam() async {
    if (isSubmitting) return;
    if (nonEmployeeId == null) {
      Get.snackbar(
        "Missing ID",
        "User ID not found. Please log in again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => isSubmitting = true);

    final score = _calculateScore();
    print("🧮 Calculated Exam Score: $score");

    final success = await controller.submitExam(
      jobId: widget.jobId,
      applicationUserId: nonEmployeeId!,
      examScore: score,
    );

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xffe0f2fe),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xff2563eb),
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Assessment Submitted",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff1e293b),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your score has been successfully recorded.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xfff1f5f9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Score: $score",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2563eb),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // يغلق الديالوج
                        Get.back(); // يرجع للصفحة السابقة
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2563eb),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      Get.snackbar(
        "Submission Failed",
        "There was an error submitting your exam.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Take Exam",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final exam = controller.selectedExam.value;
        if (exam == null) {
          return const Center(child: Text("⚠️ Failed to load exam."));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: exam.mcqs.length,
                itemBuilder: (context, index) {
                  final q = exam.mcqs[index];
                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Q${index + 1}. ${q.question}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...q.options.entries.map((opt) {
                            return RadioListTile<String>(
                              value: opt.key,
                              groupValue: q.selectedAnswer,
                              onChanged: (val) {
                                setState(() {
                                  q.selectedAnswer = val;
                                });
                              },
                              title: Text("${opt.key}. ${opt.value}"),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : _submitExam,
                icon:
                    isSubmitting
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.send, color: Colors.white),
                label: Text(
                  isSubmitting ? "Submitting..." : "Submit Exam",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2563eb),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

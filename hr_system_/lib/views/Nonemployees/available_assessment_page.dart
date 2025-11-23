import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_system_/controllers/exam_controller.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_home_page.dart';
import 'package:hr_system_/views/Nonemployees/take_exam_page.dart';

class AvailableAssessmentPage extends StatefulWidget {
  final String nonEmployeeId;
  const AvailableAssessmentPage({super.key, required this.nonEmployeeId});

  @override
  State<AvailableAssessmentPage> createState() =>
      _AvailableAssessmentPageState();
}

class _AvailableAssessmentPageState extends State<AvailableAssessmentPage> {
  final controller = Get.put(ExamController());
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    controller.fetchPassedExams(widget.nonEmployeeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        backgroundColor: const Color(0xfff8fafc), 
        elevation: 0, 
        scrolledUnderElevation: 0, 
        centerTitle: true,
        surfaceTintColor:
            Colors.transparent, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            Get.offAll(() => const NonEmployeeHomeScreen());
          },
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff2563eb)),
          );
        }

        if (controller.exams.isEmpty) {
          return _buildEmptyState();
        }

        final exam = controller.exams.first;

        const fixedDuration = 30;
        const fixedQuestions = 30;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 🧾 بطاقة الامتحان الرسمية
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xffdbeafe),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.assignment_rounded,
                            color: Color(0xff2563eb),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            exam.title,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff0f172a),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // معلومات الوقت وعدد الأسئلة
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xfff1f5f9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xffe2e8f0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _infoBox(
                            Icons.timer_outlined,
                            "Duration",
                            "$fixedDuration min",
                          ),
                          _infoBox(
                            Icons.help_outline_rounded,
                            "Questions",
                            "$fixedQuestions",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // زر بدء الامتحان
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2563eb),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Get.to(() => TakeExamPage(jobId: exam.jobId));
                        },
                        label: const Text(
                          "Start Assessment",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // الملاحظات الرسمية
              const Text(
                "Important Notes",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xff0f172a),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfff1f5f9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xffe2e8f0)),
                ),
                child: const Text(
                  "• The assessment duration is fixed to 30 minutes.\n"
                  "• There are 30 questions in total.\n"
                  "• The timer will start automatically once you enter.\n"
                  "• Ensure a stable internet connection.\n"
                  "• Do not close or refresh during the test.\n"
                  "• Your score will be automatically submitted when the time ends.",
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Color(0xff475569),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // 🎯 مكون صغير لإظهار كل معلومة (مدة / أسئلة)
  Widget _infoBox(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xff2563eb), size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xff475569),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15.5,
                color: Color(0xff1e293b),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🎯 حالة عدم وجود امتحان
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.insert_drive_file_rounded,
              color: Color(0xff94a3b8),
              size: 90,
            ),
            const SizedBox(height: 20),
            const Text(
              "No assessments are currently available.\nPlease check again later.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff475569),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () {
                controller.fetchPassedExams(widget.nonEmployeeId);
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                "Retry",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                minimumSize: const Size(160, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

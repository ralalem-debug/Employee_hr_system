import 'package:flutter/material.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_home_page.dart';
import 'assessment_questions_screen.dart';

class AssessmentAvailableScreen extends StatelessWidget {
  const AssessmentAvailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const NonEmployeeHomeScreen()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          "Online Assessments",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// بطاقة تفاصيل الاختبار
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              elevation: 5,
              shadowColor: Colors.black.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Senior Accountant Test",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 18),
                    _InfoRow(
                      icon: Icons.access_time,
                      text: "Duration: 45 Minutes",
                    ),
                    SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      text: "Deadline: 10 Sept 2025",
                    ),
                    SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.help_outline,
                      text: "Number of Questions: 10",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// زر البدء
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AssessmentQuestionsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text(
                    "Start Assessment",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 45),

            /// التعليمات
            const Text(
              "📋 Important Notes for Applicants:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  _NoteItem(
                    "The assessment will be disabled after the deadline.",
                  ),
                  _NoteItem("You can only attempt once."),
                  _NoteItem("Ensure a stable internet connection."),
                  _NoteItem("Read all instructions carefully."),
                  _NoteItem(
                    "Do not refresh or close the app while attempting.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ عنصر لعرض كل معلومة (Duration, Deadline...)
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue[800]),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87)),
      ],
    );
  }
}

/// ✅ عنصر لملاحظات التعليمات
class _NoteItem extends StatelessWidget {
  final String text;
  const _NoteItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

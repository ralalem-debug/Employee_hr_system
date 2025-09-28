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
        elevation: 0,
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              color: Colors.white,
              shadowColor: Colors.grey.withOpacity(0.3),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Senior Accountant Test",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "⏳ Duration: 45 Minutes",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    Text(
                      "📅 Deadline: 10 Sept 2025",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    Text(
                      "❓ Number of Questions: 10",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 16,
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
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 35),
            const Text(
              "📋 Important Notes for Applicants:",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
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

/// ✅ ويدجت مخصصة لكل ملاحظة عشان شكل مرتب
class _NoteItem extends StatelessWidget {
  final String text;
  const _NoteItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.blue),
          const SizedBox(width: 10),
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

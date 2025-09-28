import 'package:flutter/material.dart';
import 'assessment_result_screen.dart';

class AssessmentQuestionsScreen extends StatefulWidget {
  const AssessmentQuestionsScreen({super.key});

  @override
  State<AssessmentQuestionsScreen> createState() =>
      _AssessmentQuestionsScreenState();
}

class _AssessmentQuestionsScreenState extends State<AssessmentQuestionsScreen> {
  final List<Map<String, dynamic>> questions = [
    {
      "id": 1,
      "text": "Who is making the Web standards?",
      "options": [
        "Microsoft",
        "Mozilla",
        "Google",
        "The World Wide Web Consortium",
      ],
      "correct": "The World Wide Web Consortium",
    },
    {
      "id": 2,
      "text": "Who is making the Web standards?",
      "options": [
        "Microsoft",
        "Mozilla",
        "Google",
        "The World Wide Web Consortium",
      ],
      "correct": "The World Wide Web Consortium",
    },
  ];

  int currentIndex = 0;
  int score = 0;
  String? selectedAnswer;

  void submitAnswer() {
    if (selectedAnswer == questions[currentIndex]["correct"]) {
      score += 10;
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => AssessmentResultScreen(
                score: score,
                total: questions.length * 10,
                correctAnswers: score ~/ 10,
                totalQuestions: questions.length,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.blue[800],

        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context), // ✅ زر رجوع
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Question ${currentIndex + 1}/${questions.length}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${(((currentIndex + 1) / questions.length) * 100).round()}%",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              color: Colors.blue[800],
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 30),

            Card(
              color: const Color.fromARGB(255, 255, 255, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  question["text"],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ الاختيارات
            ...question["options"].map<Widget>((option) {
              final isSelected = option == selectedAnswer;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedAnswer = option);
                },
                child: Card(
                  color: isSelected ? Colors.blue[50] : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isSelected ? 4 : 1,
                  child: ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected ? Colors.blue[800] : Colors.grey,
                    ),
                    title: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue[800] : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),

            const Spacer(),

            // ✅ زر submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                ),
                onPressed: selectedAnswer == null ? null : submitAnswer,
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

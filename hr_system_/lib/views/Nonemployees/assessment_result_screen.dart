import 'package:flutter/material.dart';

class AssessmentResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final int correctAnswers;
  final int totalQuestions;

  const AssessmentResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final bool qualified = score >= (total * 0.6);
    final double percentage = (score / total);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.blue[800],

        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Assessment Results",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // ✅ دائرة تبين النتيجة %
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[300],
                    color: qualified ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  "${(percentage * 100).round()}%",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: qualified ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ✅ البطاقات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _resultCard(Icons.score, "Score", "$score/$total"),
                _resultCard(
                  Icons.checklist,
                  "Correct",
                  "$correctAnswers/$totalQuestions",
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ✅ رسالة النجاح أو الرسوب
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: qualified ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                qualified
                    ? "🎉 Congratulations!\nYou are qualified for the interview stage."
                    : "❌ Unfortunately, you did not pass.\nPlease try again later.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: qualified ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(
    IconData icon,
    String title,
    String subtitle, {
    Color color = Colors.blue,
  }) {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

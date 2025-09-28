import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/models/evaluation/evaluation.dart';
import 'package:hr_system_/models/evaluation/evaluation_question.dart';
import 'package:http/http.dart' as http;
import 'package:hr_system_/app_config.dart';
import 'package:hr_system_/controllers/login_controller.dart';

class CoordinatorEvaluationController extends GetxController {
  var employees = <EmployeeModel>[].obs;
  var selectedEmployeeId = "".obs;

  /// لكل موظف نسخة أسئلة
  var employeeQuestions = <String, List<EvaluationQuestion>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  /// 25 سؤال
  List<EvaluationQuestion> _generateQuestions() {
    return [
      // Work Quality
      EvaluationQuestion(
        section: "Work Quality",
        question:
            "How would you rate the accuracy and thoroughness of the employee’s work?",
      ),
      EvaluationQuestion(
        section: "Work Quality",
        question: "How well does the employee follow procedures and standards?",
      ),
      EvaluationQuestion(
        section: "Work Quality",
        question: "How consistent is the employee’s performance?",
      ),

      // Productivity & Efficiency
      EvaluationQuestion(
        section: "Productivity & Efficiency",
        question: "How well does the employee manage time and meet deadlines?",
      ),
      EvaluationQuestion(
        section: "Productivity & Efficiency",
        question: "How effectively does the employee prioritize tasks?",
      ),
      EvaluationQuestion(
        section: "Productivity & Efficiency",
        question: "How proactive is the employee in completing tasks?",
      ),

      // Communication & Collaboration
      EvaluationQuestion(
        section: "Communication & Collaboration",
        question:
            "How effectively does the employee communicate with colleagues and managers?",
      ),
      EvaluationQuestion(
        section: "Communication & Collaboration",
        question: "How well does the employee share knowledge and information?",
      ),
      EvaluationQuestion(
        section: "Communication & Collaboration",
        question: "How actively does the employee participate in teamwork?",
      ),

      // Problem Solving
      EvaluationQuestion(
        section: "Problem Solving",
        question:
            "How effectively does the employee analyze and solve problems?",
      ),
      EvaluationQuestion(
        section: "Problem Solving",
        question: "How creative is the employee in finding solutions?",
      ),
      EvaluationQuestion(
        section: "Problem Solving",
        question: "How well does the employee handle unexpected challenges?",
      ),

      // Adaptability
      EvaluationQuestion(
        section: "Adaptability",
        question: "How well does the employee adapt to new tasks or changes?",
      ),
      EvaluationQuestion(
        section: "Adaptability",
        question: "How flexible is the employee in taking on different roles?",
      ),
      EvaluationQuestion(
        section: "Adaptability",
        question: "How well does the employee handle stress or pressure?",
      ),

      // Leadership
      EvaluationQuestion(
        section: "Leadership",
        question: "How effectively does the employee take initiative?",
      ),
      EvaluationQuestion(
        section: "Leadership",
        question: "How well does the employee motivate others?",
      ),
      EvaluationQuestion(
        section: "Leadership",
        question: "How responsible is the employee in decision making?",
      ),

      // Attendance & Punctuality
      EvaluationQuestion(
        section: "Attendance & Punctuality",
        question: "How regular is the employee’s attendance?",
      ),
      EvaluationQuestion(
        section: "Attendance & Punctuality",
        question: "How punctual is the employee in reporting to work?",
      ),
      EvaluationQuestion(
        section: "Attendance & Punctuality",
        question: "How committed is the employee to company policies?",
      ),

      // Professionalism
      EvaluationQuestion(
        section: "Professionalism",
        question: "How well does the employee represent the company’s values?",
      ),
      EvaluationQuestion(
        section: "Professionalism",
        question:
            "How respectful is the employee towards colleagues and clients?",
      ),
      EvaluationQuestion(
        section: "Professionalism",
        question: "How well does the employee maintain professional behavior?",
      ),

      // Overall Performance (25th question)
      EvaluationQuestion(
        section: "Overall Performance",
        question:
            "Overall, how would you rate the employee’s contribution to the company?",
      ),
    ];
  }

  /// جلب الموظفين غير المقيّمين
  Future<void> fetchEmployees() async {
    try {
      final loginCtrl = LoginController();
      final token = await loginCtrl.getToken();

      final res = await http.get(
        Uri.parse("${AppConfig.baseUrl}/Evaluations/coordinator-team"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        employees.value = data.map((e) => EmployeeModel.fromJson(e)).toList();

        for (var emp in employees) {
          if (!employeeQuestions.containsKey(emp.id)) {
            employeeQuestions[emp.id] = _generateQuestions();
          }
        }
      } else {
        print("❌ Error fetching employees: ${res.statusCode} - ${res.body}");
      }
    } catch (e) {
      print("❌ Exception fetching employees: $e");
    }
  }

  /// تعديل تقييم سؤال لموظف
  void setScoreForEmployee(String empId, int index, int score) {
    final questions = employeeQuestions[empId];
    if (questions == null || index < 0 || index >= questions.length) return;

    questions[index].score = score;
    employeeQuestions[empId] = [...questions];
    update();
    print("⭐ $empId → Q${index + 1} = $score");
  }

  /// إرسال التقييم لموظف محدد
  Future<void> submitEvaluationForEmployee(String empId) async {
    final questions = employeeQuestions[empId] ?? [];
    if (questions.isEmpty) return;

    final totalScore = questions.fold<int>(0, (sum, q) => sum + (q.score ?? 0));
    final finalScore = (totalScore / (questions.length * 5)) * 100;

    final loginCtrl = LoginController();
    final token = await loginCtrl.getToken();

    final res = await http.post(
      Uri.parse("${AppConfig.baseUrl}/Evaluations/evaluate?employeeId=$empId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(finalScore),
    );

    print("📤 Sending Score Body: $finalScore");
    print("🔹 Response Code: ${res.statusCode}");
    print("🔹 Response Body: ${res.body}");

    if (res.statusCode == 200) {
      Get.snackbar(
        "Success",
        "Evaluation submitted for employee $empId",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
      employees.removeWhere((e) => e.id == empId);
    } else {
      Get.snackbar(
        "Error",
        "Failed to submit evaluation",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }
}

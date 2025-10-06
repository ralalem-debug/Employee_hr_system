import 'dart:convert';
import 'package:get/get.dart';
import 'package:hr_system_/app_config.dart';
import 'package:hr_system_/models/evaluation/evaluation.dart';
import 'package:http/http.dart' as http;
import 'package:hr_system_/models/evaluation/evaluation_question.dart';
import 'package:hr_system_/controllers/login_controller.dart';

class CoordinatorEvaluationController extends GetxController {
  var employees = <EmployeeModel>[].obs;
  var employeeQuestions = <String, List<EvaluationQuestion>>{}.obs;
  var isLoading = false.obs;

  /// 🟦 جلب الفريق من الـ API
  Future<void> fetchCoordinatorTeam() async {
    try {
      isLoading.value = true;

      final loginCtrl = LoginController();
      final token = await loginCtrl.getToken();

      final res = await http.get(
        Uri.parse("${AppConfig.baseUrl}/Evaluations/coordinator-team"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("🔗 URL: ${AppConfig.baseUrl}/Evaluations/coordinator-team");
      print("🔹 Status: ${res.statusCode}");
      print("🔹 Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        employees.value = data.map((e) => EmployeeModel.fromJson(e)).toList();

        // أنشئ أسئلة أولية لكل موظف
        for (var emp in employees) {
          employeeQuestions[emp.id] = _generateQuestions();
        }
      } else {
        Get.snackbar("Error", "Failed to fetch coordinator team");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🟩 أسئلة التقييم الأساسية
  List<EvaluationQuestion> _generateQuestions() {
    return [
      EvaluationQuestion(
        section: "Teamwork",
        question: "Does the employee collaborate effectively with others?",
      ),
      EvaluationQuestion(
        section: "Communication",
        question: "Does the employee communicate clearly and professionally?",
      ),
      EvaluationQuestion(
        section: "Punctuality",
        question: "Is the employee on time and reliable?",
      ),
      EvaluationQuestion(
        section: "Initiative",
        question: "Does the employee show initiative in their work?",
      ),
      EvaluationQuestion(
        section: "Quality of Work",
        question: "Is the employee’s work accurate and thorough?",
      ),
    ];
  }

  /// ⭐ تغيير العلامة للسؤال
  void setScoreForEmployee(String empId, int questionIndex, int score) {
    final questions = employeeQuestions[empId];
    if (questions != null && questionIndex < questions.length) {
      questions[questionIndex].score = score;
      employeeQuestions[empId] = List.from(questions); // لتحديث الـ Obx
    }
  }

  /// 🚀 إرسال التقييم للموظف
  Future<void> submitEvaluationForEmployee(String empId) async {
    try {
      final loginCtrl = LoginController();
      final token = await loginCtrl.getToken();

      final questions = employeeQuestions[empId];
      if (questions == null || questions.isEmpty) {
        Get.snackbar("Error", "No questions found for this employee");
        return;
      }

      final payload = {
        "employeeId": empId,
        "answers": questions.map((q) => q.toJson()).toList(),
      };

      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}/Evaluations/submit"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      print("📡 Submitting Evaluation for $empId");
      print("🔹 Status: ${res.statusCode}");
      print("🔹 Body: ${res.body}");

      if (res.statusCode == 200) {
        Get.snackbar("Success", "Evaluation submitted successfully");
      } else {
        Get.snackbar("Error", "Failed to submit evaluation");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchCoordinatorTeam();
  }
}

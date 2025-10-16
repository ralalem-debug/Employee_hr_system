import 'dart:convert';
import 'package:get/get.dart';
import 'package:hr_system_/models/exam_model.dart';
import 'package:http/http.dart' as http;

class ExamController extends GetxController {
  var exams = <ExamSummary>[].obs;
  var selectedExam = Rxn<ExamModel>();
  var isLoading = false.obs;
  var errorMessage = "".obs;

  final String baseUrl = "http://46.185.162.66:30212/api";

  Future<void> fetchPassedExams(String nonEmployeeId) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final url = "$baseUrl/exam/passed/$nonEmployeeId";
      print("📡 Fetching exams from: $baseUrl");

      final res = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
      );

      print("🔹 Response status: ${res.statusCode}");
      print("🔹 Response body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data is List && data.isNotEmpty && data.first is String) {
          exams.value =
              data
                  .map(
                    (jobId) => ExamSummary(
                      jobId: jobId,
                      title: "Job Assessment",
                      duration: 45,
                      numQuestions: 10,
                    ),
                  )
                  .toList();

          print(" Loaded ${exams.length} job(s) from API (List<String>).");
        } else if (data is List && data.isNotEmpty && data.first is Map) {
          exams.value = data.map((e) => ExamSummary.fromJson(e)).toList();
          print(" Loaded ${exams.length} job(s) from API (List<Map>).");
        } else {
          exams.clear();
          errorMessage.value = "⚠️ No data returned from API.";
          print(errorMessage.value);
        }
      } else if (res.statusCode == 404) {
        exams.clear();
        final body = jsonDecode(res.body);
        final detail = body['detail'] ?? "No assessments available.";
        errorMessage.value = " $detail";
        print(" No assessments found for this user (404).");
      } else {
        exams.clear();
        errorMessage.value = " Server Error: ${res.statusCode}";
        print(errorMessage.value);
      }
    } catch (e) {
      exams.clear();
      errorMessage.value = " Error fetching exams: $e";
      print(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchExamByJobId(String jobId) async {
    try {
      isLoading.value = true;

      final url = "$baseUrl/exam/$jobId";
      print("📡 Fetching exam details from: $url");

      final res = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
      );

      print("🔹 Response status: ${res.statusCode}");
      print("🔹 Response body: ${res.body}");

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);

        // ✅ يتعامل مع أي شكل للـ JSON
        if (json["exam"] is List) {
          // الحالة اللي السيرفر يرجع فيها exam كـ List
          selectedExam.value = ExamModel.fromJson({
            "exam": null,
            "mcqs": json["exam"],
          });
        } else if (json["mcqs"] is List) {
          selectedExam.value = ExamModel.fromJson(json);
        } else {
          throw Exception("Invalid exam data format");
        }

        print(
          "✅ Exam loaded successfully with ${selectedExam.value?.mcqs.length ?? 0} questions.",
        );
      } else {
        selectedExam.value = null;
        print("❌ Failed to load exam (Status: ${res.statusCode}).");
      }
    } catch (e) {
      selectedExam.value = null;
      print("❌ Error fetching exam: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitExam({
    required String jobId,
    required String applicationUserId,
    required int examScore,
  }) async {
    try {
      final url = "$baseUrl/exam/submit";
      final body = jsonEncode({
        "job_id": jobId,
        "application_user_id": applicationUserId,
        "exam_score": examScore,
      });

      print("📤 Submitting exam to: $url");
      print("📦 Body: $body");

      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("📥 Response status: ${res.statusCode}");
      print("📥 Response body: ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        print("✅ Exam submitted successfully!");
        return true;
      } else {
        print("❌ Failed to submit exam (status: ${res.statusCode}).");
        return false;
      }
    } catch (e) {
      print("❌ Error submitting exam: $e");
      return false;
    }
  }
}

// 🧩 Model for exam summary
class ExamSummary {
  final String jobId;
  final String title;
  final int duration;
  final int numQuestions;

  ExamSummary({
    required this.jobId,
    required this.title,
    required this.duration,
    required this.numQuestions,
  });

  factory ExamSummary.fromJson(Map<String, dynamic> json) {
    return ExamSummary(
      jobId: json['job_id'] ?? '',
      title: json['title'] ?? 'Unknown Exam',
      duration: json['duration'] ?? 0,
      numQuestions: json['num_questions'] ?? 0,
    );
  }
}

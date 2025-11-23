class ExamModel {
  final String? section;
  final String? instructions;
  final int? timeLimitMinutes;
  final List<McqModel> mcqs;

  ExamModel({
    this.section,
    this.instructions,
    this.timeLimitMinutes,
    required this.mcqs,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    // ✅ يتعامل مع كل الحالات الممكنة
    final mcqList = (json["mcqs"] ?? json["exam"]) as List? ?? [];

    return ExamModel(
      section: json["section"] ?? "",
      instructions: json["instructions"] ?? "",
      timeLimitMinutes: json["time_limit_minutes"] ?? 0,
      mcqs: mcqList.map((e) => McqModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "section": section,
      "instructions": instructions,
      "time_limit_minutes": timeLimitMinutes,
      "mcqs": mcqs.map((e) => e.toJson()).toList(),
    };
  }
}

class McqModel {
  final String question;
  final Map<String, String> options;
  final String correctAnswer;
  final String? skill;
  final String? difficulty;
  final String? rationale;
  String? selectedAnswer;

  McqModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.skill,
    this.difficulty,
    this.rationale,
    this.selectedAnswer,
  });

  factory McqModel.fromJson(Map<String, dynamic> json) {
    final opts = Map<String, String>.from(json["options"] ?? {});
    return McqModel(
      question: json["question"] ?? "", 
      options: opts,
      correctAnswer: json["correct"] ?? "",
      skill: json["skill"],
      difficulty: json["difficulty"],
      rationale: json["rationale"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "question": question,
      "options": options,
      "correct": correctAnswer,
      "skill": skill,
      "difficulty": difficulty,
      "rationale": rationale,
      "selected_answer": selectedAnswer,
    };
  }
}

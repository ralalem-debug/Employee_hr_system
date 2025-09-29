class Mcq {
  final String question;
  final Map<String, String> options;
  final String correct;
  final String skill;
  final String difficulty;
  final String? rationale;

  Mcq({
    required this.question,
    required this.options,
    required this.correct,
    required this.skill,
    required this.difficulty,
    this.rationale,
  });

  factory Mcq.fromJson(Map<String, dynamic> json) {
    return Mcq(
      question: json['mcq'],
      options: Map<String, String>.from(json['options']),
      correct: json['correct'],
      skill: json['skill'],
      difficulty: json['difficulty'],
      rationale: json['rationale'],
    );
  }
}

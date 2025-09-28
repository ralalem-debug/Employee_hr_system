class EvaluationQuestion {
  final String section;
  final String question;
  int? score;

  EvaluationQuestion({
    required this.section,
    required this.question,
    this.score,
  });

  Map<String, dynamic> toJson() {
    return {'section': section, 'question': question, 'score': score};
  }

  factory EvaluationQuestion.fromJson(Map<String, dynamic> json) {
    return EvaluationQuestion(
      section: json['section'],
      question: json['question'],
      score: json['score'],
    );
  }
}

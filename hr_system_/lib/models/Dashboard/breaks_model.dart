class BreakModel {
  final String breakId;
  final String name;
  final String duration;
  final String? remainingTime;

  BreakModel({
    required this.breakId,
    required this.name,
    required this.duration,
    this.remainingTime,
  });

  factory BreakModel.fromJson(Map<String, dynamic> json) {
    return BreakModel(
      breakId: json['breakId'] ?? json['id'],
      name: json['name'],
      duration: json['duration'],
      remainingTime:
          json['remainingTime'], // nullable, عادي لو مش موجودة دايمًا
    );
  }
}

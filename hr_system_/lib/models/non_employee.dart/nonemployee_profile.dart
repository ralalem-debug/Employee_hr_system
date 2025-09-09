class NonEmployeeProfile {
  final String nonEmployeeId;
  final String fullNameE;
  final String fullNameA;
  final String gender;
  final String city;
  final String email;
  final String phone;
  final String cvUrl;

  NonEmployeeProfile({
    required this.nonEmployeeId,
    required this.fullNameE,
    required this.fullNameA,
    required this.gender,
    required this.city,
    required this.email,
    required this.phone,
    required this.cvUrl,
  });

  /// 🔹 تحويل JSON → Model
  factory NonEmployeeProfile.fromJson(Map<String, dynamic> json) {
    return NonEmployeeProfile(
      nonEmployeeId: json["nonEmployeeId"] ?? "",
      fullNameE: json["fullNameE"] ?? "",
      fullNameA: json["fullNameA"] ?? "",
      gender: json["gender"] ?? "",
      city: json["city"] ?? "",
      email: json["email"] ?? "",
      phone: json["phoneNumber"] ?? "",
      cvUrl: json["cvUrl"] ?? "",
    );
  }

  /// 🔹 تحويل Model → JSON (مفيد لو احتجت تبعته)
  Map<String, dynamic> toJson() {
    return {
      "nonEmployeeId": nonEmployeeId,
      "fullNameE": fullNameE,
      "fullNameA": fullNameA,
      "gender": gender,
      "city": city,
      "email": email,
      "phoneNumber": phone,
      "cvUrl": cvUrl,
    };
  }
}

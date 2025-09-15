class NonEmployeeProfile {
  final String fullNameE;
  final String fullNameA;
  final String gender;
  final String city;
  final String email;
  final String phone;
  final String cvUrl; // ✅ رابط الـ CV

  NonEmployeeProfile({
    required this.fullNameE,
    required this.fullNameA,
    required this.gender,
    required this.city,
    required this.email,
    required this.phone,
    required this.cvUrl,
  });

  factory NonEmployeeProfile.fromJson(Map<String, dynamic> json) {
    return NonEmployeeProfile(
      fullNameE: json['fullNameE'] ?? "",
      fullNameA: json['fullNameA'] ?? "",
      gender: json['gender'] ?? "",
      city: json['city'] ?? "",
      email: json['email'] ?? "",
      phone: json['phoneNumber'] ?? "",
      cvUrl: json['cvUrl'] ?? "",
    );
  }

  /// ✅ دالة لإرجاع اسم الملف فقط بدل الرابط الطويل
  String getCVFileName() {
    if (cvUrl.isEmpty) return "No CV uploaded";
    return cvUrl.split('/').last;
  }
}

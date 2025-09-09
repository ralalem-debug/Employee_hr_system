class NonEmployeeProfile {
  final String fullNameE;
  final String fullNameA;
  final String gender;
  final String city;
  final String email;
  final String phone;
  final String cvUrl;

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
      cvUrl: json['cvUrl'] ?? json['cv'] ?? "",
    );
  }
}

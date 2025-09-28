class EmployeeModel {
  final String id;
  final String name;

  EmployeeModel({required this.id, required this.name});

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['employeeId'] ?? "", // ✅ هون كان السبب
      name: json['name'] ?? "",
    );
  }
}

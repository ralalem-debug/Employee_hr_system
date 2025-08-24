class ProfessionalInfoModel {
  final int? departmentId;
  final int? jobTitleId;
  final String departmentName;
  final String jobTitleName;
  final String employmentType;
  final String email;
  final double salary;
  final String iban;
  final String hireDate;
  final String? terminationDate;
  final int annualLeaveBalance;
  final int sickLeaveBalance;

  ProfessionalInfoModel({
    this.departmentId,
    this.jobTitleId,
    required this.departmentName,
    required this.jobTitleName,
    required this.employmentType,
    required this.email,
    required this.salary,
    required this.iban,
    required this.hireDate,
    this.terminationDate,
    required this.annualLeaveBalance,
    required this.sickLeaveBalance,
  });

  factory ProfessionalInfoModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalInfoModel(
      departmentId:
          json['departmentId'] is int
              ? json['departmentId']
              : int.tryParse("${json['departmentId']}"),
      jobTitleId:
          json['jobTitleId'] is int
              ? json['jobTitleId']
              : int.tryParse("${json['jobTitleId']}"),
      departmentName: json['departmentName'] ?? '',
      jobTitleName: json['jobTitleName'] ?? '',
      employmentType: json['employmentType'] ?? '',
      email: json['email'] ?? '',
      salary:
          (json['salary'] is num)
              ? (json['salary'] as num).toDouble()
              : double.tryParse("${json['salary']}") ?? 0,
      iban: json['iban'] ?? '',
      hireDate: json['hireDate'] ?? '',
      terminationDate: json['terminationDate'],
      annualLeaveBalance: json['annualLeaveBalance'] ?? 0,
      sickLeaveBalance: json['sickLeaveBalance'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "departmentId": departmentId,
      "jobTitleId": jobTitleId,
      "departmentName": departmentName,
      "jobTitleName": jobTitleName,
      "employmentType": employmentType,
      "email": email,
      "salary": salary,
      "iban": iban,
      "hireDate": hireDate,
      "terminationDate": terminationDate,
      "annualLeaveBalance": annualLeaveBalance,
      "sickLeaveBalance": sickLeaveBalance,
    };
  }
}

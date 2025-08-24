class SalaryAdvanceModel {
  final String? salaryAdvanceRequestId;
  final String? requestDate;
  final String subject;
  final int amount;
  final String deductFromMonth;
  final String? status;

  SalaryAdvanceModel({
    this.salaryAdvanceRequestId,
    this.requestDate,
    required this.subject,
    required this.amount,
    required this.deductFromMonth,
    this.status,
  });

  factory SalaryAdvanceModel.fromJson(Map<String, dynamic> json) {
    return SalaryAdvanceModel(
      salaryAdvanceRequestId: json['salaryAdvanceRequestId'],
      requestDate: json['requestDate'],
      subject: json['subject'] ?? "Salary Advance",
      amount:
          (json['amount'] is int)
              ? json['amount']
              : (json['amount'] is double)
              ? (json['amount'] as double).toInt()
              : int.tryParse(json['amount'].toString()) ?? 0,
      deductFromMonth: json['deductFromMonth'] ?? "",
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "deductFromMonth": deductFromMonth,
    "subject": subject,
  };
}

class ComplaintModel {
  final String? complaintId;
  final String? date;
  final String? complaintAgainstEmployee;
  final String subject;
  final String details;

  ComplaintModel({
    this.complaintId,
    this.date,
    this.complaintAgainstEmployee,
    required this.subject,
    required this.details,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      complaintId: json['complaintId'],
      date: json['date'],
      complaintAgainstEmployee: json['complaintAgainstEmployee'],
      subject: json['subject'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() => {
    "complaintAgainstEmployeeID": null, // or the ID if you have it
    "subject": subject,
    "details": details,
  };
}

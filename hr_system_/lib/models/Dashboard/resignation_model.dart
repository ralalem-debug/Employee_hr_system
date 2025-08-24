// models/resignation_request_model.dart
class ResignationRequestModel {
  final String note;
  final String lastWorkingDay;

  ResignationRequestModel({required this.note, required this.lastWorkingDay});

  Map<String, dynamic> toJson() => {
    "note": note,
    "lastWorkingDay": lastWorkingDay,
  };
}

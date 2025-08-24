class PersonalInfoModel {
  final String employeeId;
  final String fullNameArb;
  final String fullNameEng;
  final String personalEmail;
  final String phoneNumber;
  final String birthday;
  final String maritalStatus;
  final String gender;
  final String nationality;
  final String nationalId;
  final String iDno;
  final String? passportNumber;
  final String? serialNo;
  final String residency;
  final String birthPlace;
  final String address;

  PersonalInfoModel({
    required this.employeeId,
    required this.fullNameArb,
    required this.fullNameEng,
    required this.personalEmail,
    required this.phoneNumber,
    required this.birthday,
    required this.maritalStatus,
    required this.gender,
    required this.nationality,
    required this.nationalId,
    required this.iDno,
    this.passportNumber,
    this.serialNo,
    required this.residency,
    required this.birthPlace,
    required this.address,
  });

  factory PersonalInfoModel.fromJson(Map<String, dynamic> j) {
    return PersonalInfoModel(
      employeeId: j['employeeId'] ?? '',
      fullNameArb: j['fullNameArb'] ?? '',
      fullNameEng: j['fullNameEng'] ?? '',
      personalEmail: j['personalEmail'] ?? '',
      phoneNumber: j['phoneNumber'] ?? '',
      birthday: j['birthday'] ?? '',
      maritalStatus: j['maritalStatus'] ?? '',
      gender: j['gender'] ?? '',
      nationality: j['nationality'] ?? '',
      nationalId: j['nationalId'] ?? '',
      iDno: j['iDno'] ?? '',
      passportNumber: j['passportNumber'],
      serialNo: j['serialno'],
      residency: j['residency'] ?? '',
      birthPlace: j['birthPlace'] ?? '',
      address: j['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "employeeId": employeeId,
    "fullNameArb": fullNameArb,
    "fullNameEng": fullNameEng,
    "personalEmail": personalEmail,
    "phoneNumber": phoneNumber,
    "birthday": birthday,
    "maritalStatus": maritalStatus,
    "gender": gender,
    "nationality": nationality,
    "nationalId": nationalId,
    "iDno": iDno,
    "passportNumber": passportNumber,
    "serialno": serialNo,
    "residency": residency,
    "birthPlace": birthPlace,
    "address": address,
  };
}

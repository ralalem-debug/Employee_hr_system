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
  final String? imageUrl;

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
    this.imageUrl,
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
      serialNo: j['serialNo'] ?? j['serialno'],
      residency: j['residency'] ?? '',
      birthPlace: j['birthPlace'] ?? '',
      address: j['address'] ?? '',
      imageUrl: j['imageUrl'],
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
    "serialNo": serialNo,
    "residency": residency,
    "birthPlace": birthPlace,
    "address": address,
    "imageUrl": imageUrl,
  };

  // ✅ copyWith يشمل كل الحقول المهمة
  PersonalInfoModel copyWith({
    String? employeeId,
    String? fullNameArb,
    String? fullNameEng,
    String? personalEmail,
    String? phoneNumber,
    String? birthday,
    String? maritalStatus,
    String? gender,
    String? nationality,
    String? nationalId,
    String? iDno,
    String? passportNumber,
    String? serialNo,
    String? residency,
    String? birthPlace,
    String? address,
    String? imageUrl,
  }) {
    return PersonalInfoModel(
      employeeId: employeeId ?? this.employeeId,
      fullNameArb: fullNameArb ?? this.fullNameArb,
      fullNameEng: fullNameEng ?? this.fullNameEng,
      personalEmail: personalEmail ?? this.personalEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthday: birthday ?? this.birthday,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      nationalId: nationalId ?? this.nationalId,
      iDno: iDno ?? this.iDno,
      passportNumber: passportNumber ?? this.passportNumber,
      serialNo: serialNo ?? this.serialNo,
      residency: residency ?? this.residency,
      birthPlace: birthPlace ?? this.birthPlace,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

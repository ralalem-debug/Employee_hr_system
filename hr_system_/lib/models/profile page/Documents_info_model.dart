class DocumentsModel {
  final String cv;
  final String universityCertificate;
  final String contract;
  final String nationalIdentity;
  final String passport;
  final String signature;
  final String other;
  final List<String> certificates;

  DocumentsModel({
    required this.cv,
    required this.universityCertificate,
    required this.contract,
    required this.nationalIdentity,
    required this.passport,
    required this.signature,
    required this.other,
    required this.certificates,
  });

  factory DocumentsModel.fromJson(Map<String, dynamic> j) {
    return DocumentsModel(
      cv: j['cv'] ?? '',
      universityCertificate: j['universitycertificate'] ?? '',
      contract: j['contract'] ?? '',
      nationalIdentity: j['nationalidentity'] ?? '',
      passport: j['passport'] ?? '',
      signature: j['signature'] ?? '',
      other: j['other'] ?? '',
      certificates:
          (j['certificates'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class DocumentsModel {
  final String cvUrl;
  final String universityCertificateUrl;
  final String contractUrl;
  final String nationalIdentity;
  final String passport;
  final List<String> certificates;

  DocumentsModel({
    required this.cvUrl,
    required this.universityCertificateUrl,
    required this.contractUrl,
    required this.nationalIdentity,
    required this.passport,
    required this.certificates,
  });

  factory DocumentsModel.fromJson(Map<String, dynamic> j) {
    return DocumentsModel(
      cvUrl: j['cvUrl'] ?? '',
      universityCertificateUrl: j['universityCertificateUrl'] ?? '',
      contractUrl: j['contractUrl'] ?? '',
      nationalIdentity: j['nationalIdentity'] ?? '',
      passport: j['passport'] ?? '',
      certificates:
          (j['certificates'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

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
    const baseUrl = "http://192.168.1.128"; // عدّل حسب السيرفر عندك

    String buildUrl(dynamic value) {
      if (value == null || (value is String && value.isEmpty)) return "";
      final str = value.toString();
      return str.startsWith("http") ? str : "$baseUrl$str";
    }

    return DocumentsModel(
      cv: buildUrl(j['cv'] ?? j['cvUrl']),
      universityCertificate: buildUrl(
        j['universitycertificate'] ?? j['universityCertificateUrl'],
      ),
      contract: buildUrl(j['contract'] ?? j['contractUrl']),
      nationalIdentity: buildUrl(
        j['nationalidentity'] ?? j['nationalIdentity'],
      ),
      passport: buildUrl(j['passport']),
      signature: buildUrl(j['signature']),
      other: buildUrl(j['other']),
      certificates:
          (j['certificates'] as List?)?.map((e) => buildUrl(e)).toList() ?? [],
    );
  }
}

import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignatureUploadController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  Future<bool> uploadSignature(File signatureFile, String employeeId) async {
    isLoading.value = true;
    errorMessage = null;

    try {
      final token = await storage.read(key: 'auth_token');

      final uri = Uri.parse(
        "http://192.168.1.131:5005/api/employee/upload-signature",
      );
      final req = http.MultipartRequest('POST', uri);

      req.files.add(
        await http.MultipartFile.fromPath('file', signatureFile.path),
      );

      // فقط إذا الـ API فعلاً بطلب employeeId كـ field
      req.fields['employeeId'] = employeeId;

      if (token != null && token.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }

      final res = await req.send();
      final resBody = await res.stream.bytesToString();

      isLoading.value = false;

      if (res.statusCode == 200) {
        print("✅ Signature uploaded");
        // ✅ Store flag in secure storage
        await storage.write(key: 'signature_done', value: 'true');
        return true;
      } else {
        errorMessage =
            "Failed to upload signature. (${res.statusCode})\n$resBody";
        print(errorMessage);
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage = "Error: $e";
      return false;
    }
  }
}

import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:hr_system_/app_config.dart';

class SignatureUploadController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;

  final storage = const FlutterSecureStorage();

  Future<bool> uploadSignature(File signatureFile) async {
    isLoading.value = true;
    errorMessage = null;

    try {
      final token = await storage.read(key: 'auth_token');

      final uri = Uri.parse("${AppConfig.baseUrl}/employee/upload-signature");
      final req = http.MultipartRequest('POST', uri);

      final bytes = await signatureFile.readAsBytes();
      req.files.add(
        http.MultipartFile.fromBytes(
          'File',
          bytes,
          filename: p.basename(signatureFile.path),
        ),
      );

      req.headers['accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }

      final res = await req.send();
      final resBody = await res.stream.bytesToString();

      isLoading.value = false;

      if (res.statusCode == 200) {
        print("✅ Signature uploaded successfully: $resBody");
        await storage.write(key: 'signature_done', value: 'true');
        return true;
      } else {
        errorMessage = "Failed (${res.statusCode}): $resBody";
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

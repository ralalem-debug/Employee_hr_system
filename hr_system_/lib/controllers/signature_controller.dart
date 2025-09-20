import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path/path.dart' as p;
import 'package:hr_system_/app_config.dart';

class SignatureUploadController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;

  final storage = const FlutterSecureStorage();
  Future<String?> fetchEmployeeId() async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) return null;

    final res = await http.get(
      Uri.parse("${AppConfig.baseUrl}/Auth/myId"),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    print("🔎 myId response: ${res.body}");

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      print("🔎 myId response: $json");
      return json['employeeId'];
    }
    return null;
  }

  Future<bool> uploadSignature(File signatureFile) async {
    final token = await storage.read(key: 'auth_token');
    print("🔑 Token: $token");

    final decoded = JwtDecoder.decode(token!);
    print("🔎 Decoded token: $decoded");

    isLoading.value = true;
    errorMessage = null;

    try {
      final token = await storage.read(key: 'auth_token');

      final uri = Uri.parse("${AppConfig.baseUrl}/employee/upload-signature");
      final req = http.MultipartRequest('POST', uri);

      // أضف الملف
      final bytes = await signatureFile.readAsBytes();
      req.files.add(
        http.MultipartFile.fromBytes(
          'File',
          bytes,
          filename: p.basename(signatureFile.path),
        ),
      );

      // الهيدرز
      req.headers['accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }

      print("📡 Uploading signature to: $uri");

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

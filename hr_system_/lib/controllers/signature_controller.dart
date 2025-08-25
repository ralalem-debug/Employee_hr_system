import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignatureUploadController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;

  Future<bool> uploadSignature(File signatureFile, String employeeId) async {
    isLoading.value = true;
    errorMessage = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final uri = Uri.parse(
        "http://192.168.1.213/api/employee/upload-signature",
      );
      final req = http.MultipartRequest('POST', uri);

      req.files.add(
        await http.MultipartFile.fromPath('file', signatureFile.path),
      );

      // فقط إذا الـ API فعلاً بطلب employeeId كـ field
      req.fields['employeeId'] = employeeId;

      if (token != null) {
        req.headers['Authorization'] = 'Bearer $token';
      }

      final res = await req.send();
      final resBody = await res.stream.bytesToString();

      isLoading.value = false;

      if (res.statusCode == 200) {
        print("✅ Signature uploaded");
        await prefs.setBool('signature_done', true);
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

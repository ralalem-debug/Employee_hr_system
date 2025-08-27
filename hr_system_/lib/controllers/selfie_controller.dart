import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SelfieController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;

  // ✅ Secure storage
  final storage = const FlutterSecureStorage();

  Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.path, "selfie_compressed.jpg");
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 900,
      minHeight: 900,
    );
    if (result == null) throw Exception("Compress failed");
    return File(result.path);
  }

  Future<bool> uploadSelfie(File imageFile, String token) async {
    isLoading.value = true;
    errorMessage = null;

    try {
      File fileToSend = imageFile;
      if (await imageFile.length() > 1024 * 1024) {
        fileToSend = await compressImage(imageFile);
      }

      final uri = Uri.parse(
        "http://192.168.1.128:5000/api/employee/upload-selfie",
      );
      final req = http.MultipartRequest('POST', uri);

      req.files.add(await http.MultipartFile.fromPath('file', fileToSend.path));

      req.headers['accept'] = 'application/json';
      req.headers['Authorization'] = 'Bearer $token';

      final res = await req.send();
      final resBody = await res.stream.bytesToString();

      isLoading.value = false;

      if (res.statusCode == 200) {
        try {
          final decoded = jsonDecode(resBody);
          print("✅ ${decoded['message'] ?? 'Uploaded'}");
        } catch (_) {
          print("✅ Selfie uploaded successfully");
        }

        // ✅ Store flag in secure storage
        await storage.write(key: 'selfie_done', value: 'true');

        return true;
      } else {
        errorMessage = "Failed to upload selfie. (${res.statusCode})\n$resBody";
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

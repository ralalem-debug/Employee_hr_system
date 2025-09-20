import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:hr_system_/app_config.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SelfieController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;

  final storage = const FlutterSecureStorage();

  // ————— Helpers —————
  void _log(String msg, {Object? err, StackTrace? st}) {
    if (kDebugMode) {
      dev.log(msg, name: 'SelfieController', error: err, stackTrace: st);
    }
  }

  String _firstN(String s, [int n = 1200]) {
    if (s.length <= n) return s;
    return '${s.substring(0, n)}... [${s.length} chars]';
  }

  String _extractServerError(String body) {
    try {
      final data = jsonDecode(body);

      final msg =
          data['message'] ?? data['error'] ?? data['detail'] ?? data['title'];
      if (msg is String && msg.trim().isNotEmpty) return msg;

      if (data['errors'] is Map) {
        final map = data['errors'] as Map;
        final parts = <String>[];
        map.forEach((k, v) {
          if (v is List)
            parts.add('$k: ${v.join(", ")}');
          else
            parts.add('$k: $v');
        });
        if (parts.isNotEmpty) return parts.join(' | ');
      }
      if (data is Map && data.isNotEmpty) return data.toString();
    } catch (_) {}
    return body;
  }

  Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      "${DateTime.now().millisecondsSinceEpoch}.jpg",
    );
    _log('Compressing: ${file.path} (size: ${await file.length()} bytes)');
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 900,
      minHeight: 900,
    );
    if (result == null) throw Exception("Compress failed");
    _log(
      'Compressed -> ${result.path} (size: ${await File(result.path).length()} bytes)',
    );
    return File(result.path);
  }

  Future<String?> fetchUserId(String token) async {
    final uri = Uri.parse("${AppConfig.baseUrl}/Auth/myId"); // ✅ ديناميكي
    _log('GET $uri');
    try {
      final res = await http
          .get(
            uri,
            headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 30));

      _log('myId status: ${res.statusCode}, body: ${_firstN(res.body)}');

      if (res.statusCode == 200) {
        final userId = res.body.replaceAll('"', '').trim();
        await storage.write(key: 'user_id', value: userId);
        return userId;
      } else {
        final msg = _extractServerError(res.body);
        errorMessage = "Failed to fetch userId (${res.statusCode}): $msg";
        return null;
      }
    } on TimeoutException catch (e, st) {
      _log('myId timeout', err: e, st: st);
      errorMessage = "Timeout while fetching userId.";
      return null;
    } on SocketException catch (e, st) {
      _log('myId network error', err: e, st: st);
      errorMessage = "Network error while fetching userId.";
      return null;
    } catch (e, st) {
      _log('myId unexpected error', err: e, st: st);
      errorMessage = "Error: $e";
      return null;
    }
  }

  Future<http.MultipartFile> _toPart(File f) async {
    final ext = p.extension(f.path).toLowerCase();
    MediaType ct;
    if (ext == '.jpg' || ext == '.jpeg') {
      ct = MediaType('image', 'jpeg');
    } else if (ext == '.png') {
      ct = MediaType('image', 'png');
    } else {
      ct = MediaType('application', 'octet-stream');
    }

    File fileToSend = f;
    final size = await f.length();
    if (size > 1024 * 1024) {
      fileToSend = await compressImage(f);
    }

    final bytes = await fileToSend.readAsBytes();
    dev.log(
      'Attach file: ${fileToSend.path} (bytes: ${bytes.length})',
      name: 'SelfieController',
    );

    return http.MultipartFile.fromBytes(
      'files',
      bytes,
      filename: p.basename(fileToSend.path),
      contentType: ct,
    );
  }

  Future<bool> uploadSelfies(List<File> images, String token) async {
    isLoading.value = true;
    errorMessage = null;

    try {
      String? userId = await storage.read(key: 'user_id');
      if (userId == null) {
        userId = await fetchUserId(token);
        if (userId == null) {
          isLoading.value = false;
          dev.log(
            'Abort: userId null -> $errorMessage',
            name: 'SelfieController',
          );
          return false;
        }
      }

      // إنشاء URI لرفع الصور
      final uri = Uri.parse(
        "http://192.168.1.164:8001/m/v1/users/$userId/refs",
      );
      final req = http.MultipartRequest('POST', uri);
      req.headers['accept'] = 'application/json';
      req.headers['Authorization'] = 'Bearer $token';

      // إضافة الصور إلى الطلب
      for (int i = 0; i < images.length; i++) {
        final f = images[i];
        req.files.add(await _toPart(f)); // إضافة كل صورة
      }

      // إرسال الطلب
      final client = http.Client();
      try {
        final res = await client.send(req).timeout(const Duration(minutes: 3));
        final body = await res.stream.bytesToString();
        dev.log('Status: ${res.statusCode}', name: 'SelfieController');
        dev.log(
          'Response body: ${body.length > 800 ? body.substring(0, 800) + '...' : body}',
          name: 'SelfieController',
        );

        if (res.statusCode == 200) {
          isLoading.value = false;
          await storage.write(key: 'selfie_done', value: 'true');
          return true;
        }

        // في حالة فشل رفع الصور
        try {
          final dec = jsonDecode(body);
          errorMessage =
              dec is Map ? (dec['message']?.toString() ?? body) : body;
        } catch (_) {
          errorMessage = body;
        }
        return false;
      } on TimeoutException {
        errorMessage = 'Timeout while uploading selfies.';
        dev.log(errorMessage!, name: 'SelfieController');
        return false;
      } on SocketException {
        errorMessage = 'Network error while uploading selfies.';
        dev.log(errorMessage!, name: 'SelfieController');
        return false;
      } finally {
        client.close();
      }
    } catch (e, st) {
      isLoading.value = false;
      errorMessage = 'Unexpected error: $e';
      dev.log(
        errorMessage!,
        name: 'SelfieController',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }
}

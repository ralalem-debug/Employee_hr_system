import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../app_config.dart';

class ForgetPasswordController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;

  static const _timeout = Duration(seconds: 15);

  Uri _u(String path) {
    final b = Uri.parse(AppConfig.baseUrl); // ex: http://x.x.x.x/api
    final basePath =
        b.path.endsWith('/') ? b.path.substring(0, b.path.length - 1) : b.path;
    final addPath = path.startsWith('/') ? path.substring(1) : path;
    return b.replace(path: '$basePath/$addPath');
  }

  Future<bool> sendCode(String email) async {
    isLoading.value = true;
    errorMessage = null;

    if (email.trim().isEmpty) {
      errorMessage = "Email is required!";
      isLoading.value = false;
      return false;
    }

    try {
      final res = await http
          .post(
            _u('/Auth/forgot-password'),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"email": email.trim()}),
          )
          .timeout(_timeout);

      isLoading.value = false;

      if (res.statusCode == 200) {
        return true;
      } else {
        try {
          final body = jsonDecode(res.body);
          if (body is Map && body['message'] is String) {
            errorMessage = body['message'];
          } else if (body is Map && body['error'] is String) {
            errorMessage = body['error'];
          } else {
            errorMessage = "Failed to send code! (${res.statusCode})";
          }
        } catch (_) {
          errorMessage = "Failed to send code! (${res.statusCode})";
        }
        return false;
      }
    } on TimeoutException {
      isLoading.value = false;
      errorMessage = "Connection timeout. Please try again.";
      return false;
    } catch (e) {
      isLoading.value = false;
      errorMessage = "Error: $e";
      return false;
    }
  }
}

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hr_system_/app_config.dart';

class VerifyCodeController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;
  String? token;

  Future<bool> verifyCode(String code) async {
    isLoading.value = true;

    final url = Uri.parse("${AppConfig.baseUrl}/Auth/verify-reset-code");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"code": code}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        token = data["token"];
        return true;
      } else {
        errorMessage = "Invalid or expired code!";
        return false;
      }
    } catch (e) {
      errorMessage = "Network error: $e";
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

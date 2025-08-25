import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VerifyCodeController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;
  String? token;

  Future<bool> verifyCode(String code) async {
    isLoading.value = true;
    final url = Uri.parse(
      "http://192.168.1.131:5005/api/Auth/verify-reset-code",
    );
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"code": code}),
    );
    isLoading.value = false;
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      token = data["token"];
      return true;
    } else {
      errorMessage = "Invalid or expired code!";
      return false;
    }
  }
}

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ForgetPasswordController extends GetxController {
  var isLoading = false.obs;
  String? errorMessage;

  Future<bool> sendCode(String email) async {
    isLoading.value = true;
    final url = Uri.parse("http://192.168.1.128:5000/api/Auth/forgot-password");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    isLoading.value = false;
    if (res.statusCode == 200) {
      return true;
    } else {
      errorMessage = "Failed to send code!";
      return false;
    }
  }
}

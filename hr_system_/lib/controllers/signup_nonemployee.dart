import 'package:get/get.dart';
import 'package:hr_system_/models/signup_nonemployee_model.dart';
import 'package:http/http.dart' as http;
import 'package:hr_system_/app_config.dart';

class NonEmployeeController extends GetxController {
  var isLoading = false.obs;
  String baseUrl = "${AppConfig.baseUrl}/nonemployees"; // ✅ ديناميكي

  Future<bool> signUp(NonEmployeeSignUpModel model) async {
    isLoading.value = true;

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/signup'));

    request.fields['FullNameE'] = model.fullNameE;
    request.fields['FullNameA'] = model.fullNameA;
    request.fields['Email'] = model.email;
    request.fields['PhoneNumber'] = model.phoneNumber;
    request.fields['Gender'] = model.gender;
    request.fields['City'] = model.city;
    request.fields['Password'] = model.password;
    request.fields['ConfirmPassword'] = model.confirmPassword;

    // ✅ رفع CV
    request.files.add(await http.MultipartFile.fromPath('CV', model.cvPath));

    try {
      var response = await request.send();
      isLoading.value = false;

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Signup successful ✅");
        return true;
      } else {
        final resStr = await response.stream.bytesToString();
        Get.snackbar("Error", "Failed: $resStr");
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Network error: $e");
      return false;
    }
  }
}

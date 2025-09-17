import 'package:get/get.dart';

class SettingsController extends GetxController {
  RxBool isDarkMode = false.obs;
  RxBool pushNotifications = false.obs;

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    // تطبيق التغيير حسب الحالة
  }

  void togglePushNotifications(bool value) {
    pushNotifications.value = value;
  }
}

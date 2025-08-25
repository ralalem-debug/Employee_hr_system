import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/views/after%20login/change_password_screen.dart';
import 'package:hr_system_/views/notification_page.dart';
<<<<<<< HEAD
=======
import 'package:hr_system_/views/settings/about_us.dart';
import 'package:hr_system_/views/settings/privacypolicy.dart';
>>>>>>> 2265dd68297062975891d110e94bb810b8a028b2
import 'package:hr_system_/views/settings/settings_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'views/splash_screen.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';
import 'views/forgetpass/forget_password_screen.dart';
import 'views/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en', null);
  runApp(const OnsetWayApp());
}

class OnsetWayApp extends StatelessWidget {
  const OnsetWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Onset Way HR',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/forget-password', page: () => ForgetPasswordScreen()),
        GetPage(name: '/settings', page: () => SettingsScreen()),
        GetPage(name: '/notifications', page: () => NotificationsScreen()),
        GetPage(
          name: '/change_pass',
          page: () {
            final args = Get.arguments as Map<String, dynamic>;
            return ChangePasswordScreen(
              token: args['token'],
              isFirstLogin: args['isFirstLogin'] ?? false,
            );
          },
        ),
        GetPage(name: '/profile', page: () => ProfileScreen()),
        GetPage(name: '/aboutus', page: () => AboutUsScreen()),
        GetPage(name: '/privacypolicy', page: () => PrivacyPolicyScreen()),
      ],
    );
  }
}

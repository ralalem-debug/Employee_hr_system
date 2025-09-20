import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/app_config.dart';
import 'package:hr_system_/views/debugdiscovery.dart';
import 'views/splash_screen.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';
import 'views/after login/change_password_screen.dart';
import 'views/forgetpass/forget_password_screen.dart';
import 'views/settings/settings_page.dart';
import 'views/notification_page.dart';
import 'views/profile/profile_screen.dart';
import 'views/settings/about_us.dart';
import 'views/settings/privacypolicy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await debugDiscovery();
  await AppConfig.init();
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
        GetPage(name: '/', page: () => const SplashScreen()),
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

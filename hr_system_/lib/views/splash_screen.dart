import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/app_config.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2)); // خلي الأنيميشن يبين

    if (AppConfig.baseUrl.isEmpty) {
      Get.offAll(
        () => const LoginScreen(),
        arguments: {
          "error": "لم يتم العثور على السيرفر. يرجى المحاولة لاحقًا.",
        },
      );
    } else {
      _goLogin();
    }
  }

  void _goLogin() {
    Get.offAll(() => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.9,
              child: Image.asset('images/bg_pattern.png', fit: BoxFit.cover),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Image.asset('images/splash_logo.png', width: 250),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

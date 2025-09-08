import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/views/non_employee_home_page.dart';
import 'package:hr_system_/views/signup_page.dart';
import '../controllers/login_controller.dart';
import '../views/home_screen.dart';
import '../views/after login/change_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final LoginController _controller = LoginController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _visible = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => _visible = true);
    });
  }

  Future<void> _attemptLogin() async {
    setState(() => _isLoading = true);

    final result = await _controller.login();

    setState(() => _isLoading = false);

    if (result.success) {
      if (result.isFirstLogin && result.role?.toLowerCase() == "employee") {
        Get.offAll(
          () => ChangePasswordScreen(
            token: result.token ?? "",
            isFirstLogin: result.isFirstLogin,
          ),
        );
      } else if (result.role?.toLowerCase() == "employee") {
        Get.offAll(() => const HomeScreen());
      } else {
        Get.offAll(() => const NonEmployeeHomeScreen());
      }
    } else {
      Get.snackbar(
        "Error",
        result.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Stack(
        children: [
          // خلفية فيها باترن
          Positioned.fill(
            child: Opacity(
              opacity: 0.90,
              child: Image.asset('images/bg_pattern.png', fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      child: _buildLoginForm(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Image.asset('images/login_logo.png', width: 180),
        const SizedBox(height: 20),
        const Text(
          "Welcome!",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 40),
        TextField(
          controller: _controller.emailOrUserController,
          decoration: const InputDecoration(
            labelText: "Username or Email",
            prefixIcon: Icon(Icons.account_circle_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _controller.passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: "Password",
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _attemptLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child:
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 12),
        // رابط SignUp بخط صغير
        GestureDetector(
          onTap: () => Get.to(() => const NonEmployeeSignUpPage()),
          child: const Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 150),
        const Text(
          "©2025 by Onset Way L.L.C",
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/views/after%20login/change_password_screen.dart';
import 'package:hr_system_/views/home_screen.dart';
import '../controllers/login_controller.dart';
import '../models/login_model.dart';
import 'forgetpass/forget_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginController _controller = Get.put(LoginController());

  bool _obscurePassword = true;
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
    _controller.isLoading.value = true;

    final loginData = LoginModel(
      userName: _idController.text.trim(),
      password: _passwordController.text,
    );

    final success = await _controller.login(loginData);

    _controller.isLoading.value = false;

    if (success) {
      if (_controller.isFirstLogin.value) {
        Get.offAll(
          () => ChangePasswordScreen(
            token: _controller.token ?? "",
            isFirstLogin: _controller.isFirstLogin.value,
          ),
        );
      } else {
        Get.offAll(() => const HomeScreen());
      }
    }
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "About Onset Way HR",
              style: TextStyle(color: Colors.blue),
            ),
            content: const Text(
              "Onset Way HR is a smart human resources platform.\n"
              "It helps you manage attendance, requests, breaks, and track your performance easily.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Stack(
        children: [
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
                      child: Obx(() => _buildLoginForm()),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 20,
            child: GestureDetector(
              onTap: _showAbout,
              child: Icon(
                Icons.help_outline,
                color: Colors.grey.shade700,
                size: 26,
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
          controller: _idController,
          decoration: const InputDecoration(
            labelText: "Employee ID",
            prefixIcon: Icon(Icons.badge_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
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
            errorText:
                _controller.showError.value && !_controller.isFirstLogin.value
                    ? _controller.lastErrorMessage
                    : null,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Get.to(() => ForgetPasswordScreen()),
            child: const Text(
              "Forgot Password?",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _controller.isLoading.value ? null : _attemptLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child:
                _controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

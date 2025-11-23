import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_home_page.dart';
import 'package:hr_system_/views/Nonemployees/signup_page.dart';
import 'package:hr_system_/views/forgetpass/forget_password_screen.dart';
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
  String? _errorMessage;

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _controller.login();

    setState(() => _isLoading = false);

    if (result.success) {
      final roles = result.roles?.map((r) => r.toLowerCase()).toList() ?? [];

      if (roles.contains("employee")) {
        if (result.isFirstLogin) {
          Get.offAll(
            () => ChangePasswordScreen(
              token: result.token ?? "",
              isFirstLogin: result.isFirstLogin,
            ),
          );
        } else {
          Get.offAll(() => const HomeScreen());
        }
      } else if (roles.contains("nonemployee")) {
        Get.offAll(() => const NonEmployeeHomeScreen());
      } else {
        setState(() => _errorMessage = "Unknown role(s): ${roles.join(", ")}");
      }
    } else {
      String backendMessage = result.message.trim();
      final lowerMsg = backendMessage.toLowerCase();

      // 🔹 ترجمات ودّية لرسائل السيرفر (Frontend explanation)
      String friendlyExplanation = "";

      if (lowerMsg.contains("locked until")) {
        friendlyExplanation =
            "Your account has been temporarily locked after multiple failed attempts.\nPlease wait until the shown time or reset your password.";
      } else if (lowerMsg.contains("wrong password") ||
          lowerMsg.contains("incorrect password") ||
          lowerMsg.contains("401") ||
          lowerMsg.contains("unauthorized")) {
        friendlyExplanation =
            "Make sure your username and password are correct.";
      } else if (lowerMsg.contains("3 time") ||
          lowerMsg.contains("verification link")) {
        friendlyExplanation =
            "You’ve entered the wrong password several times.\nA verification link was sent to your email.";
      } else if (lowerMsg.contains("timeout")) {
        friendlyExplanation =
            "The request took too long. Please try again later.";
      } else if (lowerMsg.contains("network")) {
        friendlyExplanation =
            "Please check your internet connection and try again.";
      } else {
        // fallback explanation
        friendlyExplanation =
            "If this issue continues, please contact your system administrator.";
      }

      // 🔹 إعداد الرسالة للعرض (الأصلية + التوضيح)
      String finalMessage =
          backendMessage.isNotEmpty
              ? "$backendMessage\n\n💬 $friendlyExplanation"
              : "Login failed. Please try again.";

      setState(() => _errorMessage = finalMessage);
    }
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
              opacity: 0.9,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),

        /// LOGO
        Image.asset('images/login_logo.png', width: 160),
        const SizedBox(height: 25),

        /// TITLE
        const Text(
          "Welcome!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 30),

        /// USERNAME
        TextField(
          controller: _controller.emailOrUserController,
          decoration: InputDecoration(
            labelText: "Username or Email",
            labelStyle: const TextStyle(fontSize: 14),
            prefixIcon: const Icon(Icons.account_circle_outlined),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          style: const TextStyle(fontSize: 14),
        ),

        const SizedBox(height: 15),

        /// PASSWORD
        TextField(
          controller: _controller.passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: const TextStyle(fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          style: const TextStyle(fontSize: 14),
        ),

        /// هنا تحت الباسوورد مباشرة
        const SizedBox(height: 6),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Get.to(() => ForgetPasswordScreen()),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 26),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "Forgot Password?",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        /// بعدين error message (لو موجود)
        const SizedBox(height: 8),

        AnimatedOpacity(
          opacity: _errorMessage != null ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              _errorMessage ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// LOGIN BUTTON
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _attemptLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),

        const SizedBox(height: 14),

        /// SIGN UP
        GestureDetector(
          onTap: () => Get.to(() => const NonEmployeeSignUpPage()),
          child: Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 120),

        /// FOOTER
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

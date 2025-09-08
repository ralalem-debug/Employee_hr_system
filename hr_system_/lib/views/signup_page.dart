import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hr_system_/controllers/signup_nonemployee.dart';
import 'package:hr_system_/models/signup_nonemployee_model.dart';

class NonEmployeeSignUpPage extends StatefulWidget {
  const NonEmployeeSignUpPage({Key? key}) : super(key: key);

  @override
  State<NonEmployeeSignUpPage> createState() => _NonEmployeeSignUpPageState();
}

class _NonEmployeeSignUpPageState extends State<NonEmployeeSignUpPage> {
  final _controller = NonEmployeeController();
  final _formKey = GlobalKey<FormState>();

  String? _cvPath;
  bool _agree = false;

  final nameE = TextEditingController();
  final nameA = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final gender = TextEditingController();
  final city = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () =>
            _controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        Center(
                          child: Image.asset(
                            "images/login_logo.png",
                            width: 120,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Input fields
                        _buildTextField(nameE, "Full Name E"),
                        _buildTextField(nameA, "Full Name A"),
                        _buildTextField(email, "Email Address"),
                        _buildTextField(phone, "Phone number"),
                        _buildTextField(gender, "Gender"),
                        _buildTextField(city, "City"),
                        _buildTextField(password, "Password", isPassword: true),
                        _buildTextField(
                          confirmPassword,
                          "Confirm Password",
                          isPassword: true,
                        ),

                        const SizedBox(height: 8),

                        // Upload CV
                        ElevatedButton.icon(
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();
                            if (result != null) {
                              setState(() {
                                _cvPath = result.files.single.path!;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(
                            Icons.upload_file,
                            color: Colors.blue,
                          ),
                          label: Text(
                            _cvPath == null ? "Upload CV" : "CV Selected",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Terms and Conditions
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agree,
                              onChanged: (val) {
                                setState(() {
                                  _agree = val ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: "By signing up, you agree to our ",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: "Terms and Conditions",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: " and "),
                                    TextSpan(
                                      text: "Privacy Policy",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ", granting us permission to store and process your personal data for the purpose of providing services.",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // SignUp Button
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.blue, Colors.lightBlueAccent],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate() &&
                                    _cvPath != null &&
                                    _agree) {
                                  final model = NonEmployeeSignUpModel(
                                    fullNameE: nameE.text,
                                    fullNameA: nameA.text,
                                    email: email.text,
                                    phoneNumber: phone.text,
                                    gender: gender.text,
                                    city: city.text,
                                    password: password.text,
                                    confirmPassword: confirmPassword.text,
                                    cvPath: _cvPath!,
                                  );
                                  await _controller.signUp(model);
                                } else {
                                  Get.snackbar(
                                    "Error",
                                    "Please fill all fields, upload CV and agree to Terms",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red.shade100,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                "Sign up",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}

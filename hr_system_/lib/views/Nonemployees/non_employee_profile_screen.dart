import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hr_system_/controllers/login_controller.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_home_page.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:hr_system_/app_config.dart';
import '../../controllers/nonemployee_profile_controller.dart'
    show ProfileController;

class NonEmployeeProfileScreen extends StatefulWidget {
  const NonEmployeeProfileScreen({super.key});

  @override
  State<NonEmployeeProfileScreen> createState() =>
      _NonEmployeeProfileScreenState();
}

class _NonEmployeeProfileScreenState extends State<NonEmployeeProfileScreen> {
  final ProfileController _c = Get.put(ProfileController());

  final fullNameE = TextEditingController();
  final fullNameA = TextEditingController();
  final gender = TextEditingController();
  final city = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  File? cvFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _c.fetchProfile();
      final p = _c.profile.value;
      if (p != null) {
        fullNameE.text = p.fullNameE;
        fullNameA.text = p.fullNameA;
        gender.text = p.gender;
        city.text = p.city;
        email.text = p.email;
        phone.text = p.phone;
      }
    });
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  /// 🟦 Open + Download CV
  Future<void> _openAndDownloadCV() async {
    try {
      final loginController = LoginController();
      final token = await loginController.getToken();
      if (token == null) {
        Get.snackbar("Error", "No token found, please login again");
        return;
      }

      final url = "${AppConfig.baseUrl}/nonemployees/download-my-cv";
      print("🌍 [OPEN+DOWNLOAD] URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        // حفظ نسخة دائمة
        final docsDir = await getApplicationDocumentsDirectory();
        String fileName = "cv.pdf";
        final cd = response.headers['content-disposition'];
        if (cd != null && cd.contains("filename=")) {
          fileName = cd.split("filename=").last.replaceAll('"', '');
        }
        final savedFile = File("${docsDir.path}/$fileName");
        await savedFile.writeAsBytes(response.bodyBytes);

        // ✅ فتح باستخدام open_filex (مش url_launcher)
        final result = await OpenFilex.open(savedFile.path);
        print("📂 Open result: ${result.message}");

        Get.snackbar("Success", "CV saved to: ${savedFile.path}");
      } else {
        Get.snackbar("Error", "Failed (status ${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Error", "Open+Download error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.offAll(() => const NonEmployeeHomeScreen()),
        ),
      ),
      body: Obx(() {
        if (_c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final p = _c.profile.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// 🔹 الهيدر
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p?.fullNameE ?? "",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p?.email ?? "",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// 🔹 الحقول
              TextField(
                controller: fullNameE,
                decoration: _inputStyle("Full Name (English)", Icons.person),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fullNameA,
                decoration: _inputStyle(
                  "Full Name (Arabic)",
                  Icons.person_outline,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: gender,
                decoration: _inputStyle("Gender", Icons.wc),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: city,
                decoration: _inputStyle("City", Icons.location_city),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: email,
                decoration: _inputStyle("Email", Icons.email_outlined),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phone,
                decoration: _inputStyle("Phone Number", Icons.phone),
              ),
              const SizedBox(height: 20),

              /// 🔹 CV Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CV",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.description, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (p?.cvUrl ?? "").isEmpty
                                ? "No file"
                                : p!.cvUrl.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed:
                              (p?.cvUrl ?? "").isEmpty
                                  ? null
                                  : () => _openAndDownloadCV(),
                          child: const Text("Open CV"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();
                        if (result != null) {
                          setState(() {
                            cvFile = File(result.files.single.path!);
                          });
                        }
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        cvFile == null
                            ? "Upload New CV"
                            : "Selected: ${cvFile!.path.split('/').last}",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _c.updateProfile(
                      fullNameE: fullNameE.text,
                      fullNameA: fullNameA.text,
                      gender: gender.text,
                      city: city.text,
                      email: email.text,
                      phone: phone.text,
                      cvFile: cvFile,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

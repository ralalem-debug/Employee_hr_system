import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hr_system_/views/Nonemployees/non_employee_home_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
    _c.fetchProfile().then((_) {
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

  /// ✅ تجهيز رابط كامل للـ CV
  String getFullCvUrl(String? cvPath) {
    if (cvPath == null || cvPath.isEmpty) return "";
    if (cvPath.startsWith("http")) return cvPath;
    return "${AppConfig.baseUrl}$cvPath";
  }

  /// ✅ فتح CV
  Future<void> _openCV(String cvPath) async {
    final url = getFullCvUrl(cvPath);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Could not open CV");
    }
  }

  /// ✅ تحميل CV
  Future<void> _downloadCV(String cvPath) async {
    try {
      final url = getFullCvUrl(cvPath);

      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          Get.snackbar("Error", "Storage permission denied");
          return;
        }
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        String fileName = url.split('/').last;
        Directory? dir;

        if (Platform.isAndroid) {
          dir = Directory("/storage/emulated/0/Download");
        } else if (Platform.isIOS) {
          dir = await getApplicationDocumentsDirectory();
        }

        if (dir == null) {
          Get.snackbar("Error", "Could not find directory");
          return;
        }

        final file = File("${dir.path}/$fileName");
        await file.writeAsBytes(response.bodyBytes);

        Get.snackbar(
          "Success",
          "CV downloaded to: ${file.path}",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar("Error", "Failed to download CV");
      }
    } catch (e) {
      Get.snackbar("Error", "Download error: $e");
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

                    if ((p?.cvUrl ?? "").isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.description, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Current CV: ${p!.cvUrl.split('/').last}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _openCV(p.cvUrl),
                            child: const Text("Open"),
                          ),
                          TextButton(
                            onPressed: () => _downloadCV(p.cvUrl),
                            child: const Text("Download"),
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

              /// 🔹 Save Button
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

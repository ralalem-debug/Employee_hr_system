import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hr_system_/controllers/nonemployee_profile_controller.dart';

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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Obx(() {
        if (_c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
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

              // CV upload
              InkWell(
                onTap: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      cvFile = File(result.files.single.path!);
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.upload_file, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cvFile == null
                              ? "Upload CV"
                              : "Selected: ${cvFile!.path.split('/').last}",
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Save Button
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/models/profile%20page/personal_info_model.dart';
import '../../controllers/profile_controller.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  final ProfileController controller;
  const EditPersonalInfoScreen({required this.controller, Key? key})
    : super(key: key);

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController fullNameArb,
      fullNameEng,
      personalEmail,
      phoneNumber,
      birthday,
      maritalStatus,
      gender,
      nationality,
      nationalId,
      iDno,
      passportNumber,
      serialNo,
      residency,
      birthPlace,
      address;

  @override
  void initState() {
    super.initState();
    final p = widget.controller.personalInfo.value!;
    fullNameArb = TextEditingController(text: p.fullNameArb);
    fullNameEng = TextEditingController(text: p.fullNameEng);
    personalEmail = TextEditingController(text: p.personalEmail);
    phoneNumber = TextEditingController(text: p.phoneNumber);
    birthday = TextEditingController(text: p.birthday);
    maritalStatus = TextEditingController(text: p.maritalStatus);
    gender = TextEditingController(text: p.gender);
    nationality = TextEditingController(text: p.nationality);
    nationalId = TextEditingController(text: p.nationalId);
    iDno = TextEditingController(text: p.iDno);
    passportNumber = TextEditingController(text: p.passportNumber ?? "");
    serialNo = TextEditingController(text: p.serialNo ?? "");
    residency = TextEditingController(text: p.residency);
    birthPlace = TextEditingController(text: p.birthPlace);
    address = TextEditingController(text: p.address);
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Personal Info",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(fullNameArb, "Full Name (Arabic)", Icons.person),
              _buildField(
                fullNameEng,
                "Full Name (English)",
                Icons.person_outline,
              ),
              _buildField(personalEmail, "Email", Icons.email),
              _buildField(phoneNumber, "Phone", Icons.phone),
              _buildField(birthday, "Birthday", Icons.calendar_today),
              _buildField(
                maritalStatus,
                "Marital Status",
                Icons.family_restroom,
              ),
              _buildField(gender, "Gender", Icons.wc),
              _buildField(nationality, "Nationality", Icons.flag),
              _buildField(nationalId, "National ID", Icons.credit_card),
              _buildField(iDno, "ID No", Icons.perm_identity),
              _buildField(passportNumber, "Passport No", Icons.book),
              _buildField(serialNo, "Serial No", Icons.confirmation_number),
              _buildField(residency, "Residency", Icons.home),
              _buildField(birthPlace, "Birth Place", Icons.location_city),
              _buildField(address, "Address", Icons.location_on),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue.shade700,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final updated = PersonalInfoModel(
                        employeeId:
                            widget.controller.personalInfo.value!.employeeId,
                        fullNameArb: fullNameArb.text,
                        fullNameEng: fullNameEng.text,
                        personalEmail: personalEmail.text,
                        phoneNumber: phoneNumber.text,
                        birthday: birthday.text,
                        maritalStatus: maritalStatus.text,
                        gender: gender.text,
                        nationality: nationality.text,
                        nationalId: nationalId.text,
                        iDno: iDno.text,
                        passportNumber: passportNumber.text,
                        serialNo: serialNo.text,
                        residency: residency.text,
                        birthPlace: birthPlace.text,
                        address: address.text,
                      );

                      final ok = await widget.controller.updatePersonalInfo(
                        updated,
                      );

                      if (ok) {
                        Get.back();
                        Get.snackbar(
                          "Success",
                          "Personal info updated",
                          backgroundColor: Colors.green.withOpacity(0.7),
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          "Error",
                          "Failed to update",
                          backgroundColor: Colors.red.withOpacity(0.7),
                          colorText: Colors.white,
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

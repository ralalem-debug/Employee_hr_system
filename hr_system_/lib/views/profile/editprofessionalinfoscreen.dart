import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/profile_controller.dart';

class EditProfessionalInfoScreen extends StatefulWidget {
  final ProfileController controller;
  const EditProfessionalInfoScreen({required this.controller, Key? key})
    : super(key: key);

  @override
  State<EditProfessionalInfoScreen> createState() =>
      _EditProfessionalInfoScreenState();
}

class _EditProfessionalInfoScreenState
    extends State<EditProfessionalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> departments = [];
  List<Map<String, dynamic>> jobTitles = [];

  String? selectedDepartmentId;
  String? selectedJobTitleId;

  late TextEditingController employmentType,
      email,
      salary,
      iban,
      hireDate,
      terminationDate,
      annualLeave,
      sickLeave;

  @override
  void initState() {
    super.initState();
    final pro = widget.controller.professionalInfo.value!;

    // Controllers
    employmentType = TextEditingController(text: pro.employmentType);
    email = TextEditingController(text: pro.email);
    salary = TextEditingController(text: pro.salary.toString());
    iban = TextEditingController(text: pro.iban);
    hireDate = TextEditingController(text: pro.hireDate);
    terminationDate = TextEditingController(text: pro.terminationDate ?? '');
    annualLeave = TextEditingController(
      text: pro.annualLeaveBalance.toString(),
    );
    sickLeave = TextEditingController(text: pro.sickLeaveBalance.toString());

    selectedDepartmentId = pro.departmentId?.toString();
    selectedJobTitleId = pro.jobTitleId?.toString();

    _loadDropDownData();
  }

  Future<void> _loadDropDownData() async {
    final dep = await widget.controller.fetchDepartments();
    final jobs = await widget.controller.fetchJobTitles();

    setState(() {
      departments = dep;
      jobTitles = jobs;
    });
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<Map<String, dynamic>> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items:
            items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e.values.first.toString(),
                    child: Text(e.values.last.toString()),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        validator:
            (v) => v == null || v.isEmpty ? "Please select $label" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Professional Info",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildDropdown(
                "Department",
                selectedDepartmentId,
                departments,
                (v) => setState(() => selectedDepartmentId = v),
              ),
              _buildDropdown(
                "Job Title",
                selectedJobTitleId,
                jobTitles,
                (v) => setState(() => selectedJobTitleId = v),
              ),
              _buildField(employmentType, "Employment Type", Icons.work),
              _buildField(email, "Email", Icons.email),
              _buildField(
                salary,
                "Salary",
                Icons.monetization_on,
                keyboardType: TextInputType.number,
              ),
              _buildField(iban, "IBAN", Icons.credit_card),
              _buildField(hireDate, "Hire Date", Icons.calendar_today),
              _buildField(terminationDate, "Termination Date", Icons.cancel),
              _buildField(
                annualLeave,
                "Annual Leave Balance",
                Icons.beach_access,
                keyboardType: TextInputType.number,
              ),
              _buildField(
                sickLeave,
                "Sick Leave Balance",
                Icons.medical_services,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final ok = await widget.controller.updateProfessionalInfo(
                        selectedDepartmentId!,
                        selectedJobTitleId!,
                        employmentType.text,
                        email.text,
                        double.tryParse(salary.text) ?? 0,
                        iban.text,
                        hireDate.text,
                        terminationDate.text,
                        int.tryParse(annualLeave.text) ?? 0,
                        int.tryParse(sickLeave.text) ?? 0,
                      );
                      if (ok) {
                        Get.back();
                        Get.snackbar(
                          "Success",
                          "Professional info updated",
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

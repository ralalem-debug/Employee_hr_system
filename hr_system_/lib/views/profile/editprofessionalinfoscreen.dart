import 'package:flutter/material.dart';
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

    // قيم البداية للـ dropdowns
    selectedDepartmentId = pro.departmentId?.toString();
    selectedJobTitleId = pro.jobTitleId?.toString();

    // ✅ تحميل القوائم
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Professional Info",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                value: selectedDepartmentId,
                items:
                    departments.isEmpty
                        ? []
                        : departments.map((d) {
                          return DropdownMenuItem<String>(
                            value: d['departmentId'].toString(),
                            child: Text(d['departmentName']),
                          );
                        }).toList(),
                onChanged: (v) => setState(() => selectedDepartmentId = v),
                decoration: const InputDecoration(labelText: "Department"),
              ),

              const SizedBox(height: 12),

              // ✅ Job Title Dropdown
              DropdownButtonFormField<String>(
                dropdownColor: const Color.fromARGB(255, 255, 255, 255),

                value: selectedJobTitleId,
                items:
                    jobTitles.map((j) {
                      return DropdownMenuItem<String>(
                        value: j['jobTitleId'].toString(),
                        child: Text(j['title'].toString()),
                      );
                    }).toList(),
                onChanged: (v) => setState(() => selectedJobTitleId = v),
                decoration: const InputDecoration(labelText: "Job Title"),
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? "Please select a job title"
                            : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: employmentType,
                decoration: const InputDecoration(labelText: "Employment Type"),
              ),
              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextFormField(
                controller: salary,
                decoration: const InputDecoration(labelText: "Salary"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: iban,
                decoration: const InputDecoration(labelText: "IBAN"),
              ),
              TextFormField(
                controller: hireDate,
                decoration: const InputDecoration(labelText: "Hire Date"),
              ),
              TextFormField(
                controller: terminationDate,
                decoration: const InputDecoration(
                  labelText: "Termination Date",
                ),
              ),
              TextFormField(
                controller: annualLeave,
                decoration: const InputDecoration(
                  labelText: "Annual Leave Balance",
                ),
              ),
              TextFormField(
                controller: sickLeave,
                decoration: const InputDecoration(
                  labelText: "Sick Leave Balance",
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final ok = await widget.controller.updateProfessionalInfo(
                      selectedDepartmentId!, // ✅ مش null بعد الـ validator
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
                    if (ok) Navigator.pop(context);
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

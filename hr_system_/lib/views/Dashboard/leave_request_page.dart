import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/Dashboard/leave_request_controller.dart';
import '../employee_nav_bar.dart';

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({Key? key}) : super(key: key);

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  final _controller = LeaveRequestController();
  final _noteController = TextEditingController();
  String leaveType = 'Annual Leave';
  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now().add(const Duration(days: 1));
  File? selectedFile;
  bool loading = false;
  bool submitted = false;
  String? errorMsg;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart ? startDate! : endDate!;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      loading = true;
      errorMsg = null;
      submitted = false;
    });

    // جلب التوكن من الشيرد برفرنس
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      setState(() {
        loading = false;
        errorMsg = 'Please login again.';
      });
      return;
    }

    final res = await _controller.submitLeaveRequest(
      token: token,
      leaveType: leaveType,
      startDate: startDate!,
      endDate: endDate!,
      comments: _noteController.text.trim(),
      document: selectedFile,
    );

    setState(() => loading = false);

    if (res.statusCode == 200 || res.statusCode == 201) {
      setState(() => submitted = true);
    } else {
      setState(() => errorMsg = res.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              children: [
                // شعار HR هنا إذا عندك صورة
                const SizedBox(height: 50),
                Center(
                  child: Text(
                    "Leave Request",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                const SizedBox(height: 20),

                // Dropdown
                Text(
                  "Leave Type",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 7),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: leaveType,
                    items:
                        ["Annual Leave", "Sick Leave", "Unpaid Leave", "Other"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => leaveType = val!),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 17),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Start Date"),
                          const SizedBox(height: 6),
                          TextField(
                            controller: TextEditingController(
                              text:
                                  "${startDate!.day.toString().padLeft(2, '0')}/${startDate!.month.toString().padLeft(2, '0')}/${startDate!.year}",
                            ),
                            readOnly: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 10,
                              ),
                            ),
                            onTap: () => _pickDate(isStart: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("End Date"),
                          const SizedBox(height: 6),
                          TextField(
                            controller: TextEditingController(
                              text:
                                  "${endDate!.day.toString().padLeft(2, '0')}/${endDate!.month.toString().padLeft(2, '0')}/${endDate!.year}",
                            ),
                            readOnly: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 10,
                              ),
                            ),
                            onTap: () => _pickDate(isStart: false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),

                // Note Title
                Row(
                  children: [
                    const Text("Note Title"),
                    const Text(" *", style: TextStyle(color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Upload file
                const Text("Reasons"),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            selectedFile?.path.split('/').last ?? "Upload file",
                            style: TextStyle(
                              color:
                                  selectedFile == null
                                      ? Colors.grey
                                      : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0868e7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    child:
                        loading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text("Submit Request"),
                  ),
                ),
                const SizedBox(height: 18),

                if (submitted)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[600],
                            size: 23,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            "You leave request has been submitted successfully",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "and is awaiting admin app roval",
                        style: TextStyle(fontSize: 10, color: Colors.black87),
                      ),
                    ],
                  ),
                if (errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.red, fontSize: 15),
                    ),
                  ),
                const SizedBox(height: 22),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: EmployeeNavBar(currentIndex: 1),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../employee_nav_bar.dart';

class PartialLeaveRequestView extends StatefulWidget {
  const PartialLeaveRequestView({super.key});

  @override
  State<PartialLeaveRequestView> createState() => _LeaveRequestViewState();
}

class _LeaveRequestViewState extends State<PartialLeaveRequestView> {
  int _selectedIndex = 1;

  final TextEditingController reasonController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  DateTime? selectedDate;

  // 🔹 FlutterSecureStorage
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = now;
    dateController.text = _formatDate(now);
  }

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  Future<void> pickTime(BuildContext context, bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isFrom ? (fromTime ?? TimeOfDay.now()) : (toTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromTime = picked;
        } else {
          toTime = picked;
        }
      });
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = _formatDate(picked);
      });
    }
  }

  int timeOfDayToTicks(TimeOfDay t) {
    return ((t.hour * 60 + t.minute) * 60 * 10000000);
  }

  Future<void> submit(BuildContext context) async {
    if (fromTime == null || toTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end time')),
      );
      return;
    }
    if (reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the reason for leave')),
      );
      return;
    }
    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select leave date')));
      return;
    }

    // 🔹 جلب التوكن من Secure Storage
    final jwtToken = await storage.read(key: 'auth_token');
    if (jwtToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
      return;
    }

    final body = {
      "date": selectedDate!.toIso8601String(),
      "fromTime": "${_formatTime(fromTime!)}:00",
      "toTime": "${_formatTime(toTime!)}:00",
      "reason": reasonController.text.trim(),
    };

    try {
      final res = await http.post(
        Uri.parse(
          'http://192.168.1.128/api/employee/request-partial-day-leave',
        ),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully')),
        );
        Navigator.pop(context);
      } else {
        final err = jsonDecode(res.body);
        String errorMsg = 'Failed to send request';
        if (err['errors'] != null) {
          errorMsg += '\n${err['errors'].toString()}';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send request: $e')));
    }
  }

  void cancel(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateString =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} - ${_weekdayName(now.weekday)}";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 18),
              Text(
                dateString,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blueGrey.shade600,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              // Main Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.symmetric(
                  vertical: 26,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.09),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        "Partial Day Leave Request",
                        style: TextStyle(
                          fontSize: 25,
                          // fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                          color: Colors.black,
                          shadows: [
                            Shadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "Set the start and end time, reason, and date",
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Start Time
                    Text("Start Time", style: _labelStyle()),
                    const SizedBox(height: 7),
                    _inputField(
                      controller: TextEditingController(
                        text: fromTime == null ? '' : _formatTime(fromTime!),
                      ),
                      hint: "08:30",
                      readOnly: true,
                      onTap: () async {
                        await pickTime(context, true);
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 16),

                    // End Time
                    Text("End Time", style: _labelStyle()),
                    const SizedBox(height: 7),
                    _inputField(
                      controller: TextEditingController(
                        text: toTime == null ? '' : _formatTime(toTime!),
                      ),
                      hint: "05:30 PM",
                      readOnly: true,
                      onTap: () async {
                        await pickTime(context, false);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

                    // Reason
                    Text("Reason", style: _labelStyle()),
                    const SizedBox(height: 7),
                    _inputField(
                      controller: reasonController,
                      hint: "Reason for leave",
                    ),
                    const SizedBox(height: 16),

                    // Date
                    Text("Date", style: _labelStyle()),
                    const SizedBox(height: 7),
                    _inputField(
                      controller: dateController,
                      hint: "",
                      readOnly: true,
                      onTap: () async {
                        await pickDate(context);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 22),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => submit(context),
                            child: const Text("Submit"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => cancel(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue.shade700,
                              side: BorderSide(
                                color: Colors.blue.shade700,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
      bottomNavigationBar: EmployeeNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  TextStyle _labelStyle() => TextStyle(
    fontWeight: FontWeight.w500,
    color: Colors.grey.shade700,
    fontSize: 15,
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 14,
        ),
      ),
    );
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "";
    }
  }
}

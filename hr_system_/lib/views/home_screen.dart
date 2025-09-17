import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../controllers/attendance_controller.dart';
import '../models/attendance_model.dart';
import 'employee_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  AttendanceController controller = AttendanceController();

  bool isCheckedIn = false;
  bool isCheckedOut = false;
  double percent = 0.0;
  String minHalfDayText = "";
  String? checkInDisplay = "--:--";
  String? checkOutDisplay = "--:--";
  String? totalHours = "--:--";
  bool isLoading = false;
  bool isCheckOutLoading = false;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _initAttendance();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _initAttendance() async {
    AttendanceModel? attendance = await controller.fetchCheckInOutTime();
    if (attendance != null) {
      if (attendance.checkInTime != null) {
        checkInTime = DateTime.parse("2025-01-01 ${attendance.checkInTime!}");
        checkInDisplay = attendance.checkInTime;
        isCheckedIn = true;
        _startProgressAutoUpdate();
      }
      if (attendance.checkOutTime != null) {
        checkOutTime = DateTime.parse("2025-01-01 ${attendance.checkOutTime!}");
        checkOutDisplay = attendance.checkOutTime;
        isCheckedOut = true;
      }
      totalHours = attendance.totalHours ?? "--:--";
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleCheckInBox() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final isAtOffice = await controller.checkAtOffice(); // ✅ Clearer name
    if (isAtOffice) {
      DateTime? inTime = await controller.doCheckIn();
      if (inTime != null) {
        checkInTime = inTime;
        checkInDisplay = formatCheckInTime(inTime);
        isCheckedIn = true;
        minHalfDayText = "";
        _startProgressAutoUpdate();
        _showMessage("Check-in completed successfully!");
      }
    } else {
      _showMessage("⚠️ Cameras did not detect you at the office");
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _handleCheckOutBox() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            title: const Text('Confirm checkout'),
            content: const Text("Are you sure you want to check out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    if (!mounted) return;

    setState(() => isCheckOutLoading = true);

    DateTime? outTime = await controller.doCheckOut();
    if (outTime != null) {
      checkOutTime = outTime;
      checkOutDisplay = formatCheckInTime(outTime);
      isCheckedOut = true;
      _showMessage("Successful check-out!");

      AttendanceModel? attendance = await controller.fetchCheckInOutTime();
      totalHours = attendance?.totalHours ?? "--:--";
    }
    if (!mounted) return;

    setState(() => isCheckOutLoading = false);
  }

  void _startProgressAutoUpdate() {
    timer?.cancel();
    _updatePercent();
    timer = Timer.periodic(const Duration(seconds: 15), (_) {
      _updatePercent();
    });
  }

  void _updatePercent() {
    if (checkInTime == null) return;
    final now = DateTime.now();
    final halfDay = Duration(hours: 4);
    final workSoFar = now.difference(checkInTime!);
    final calculated = (workSoFar.inSeconds / halfDay.inSeconds).clamp(
      0.0,
      1.0,
    );
    if (!mounted) return;

    setState(() {
      percent = calculated;
      minHalfDayText = percent >= 1 ? "Minimum half day time  reached" : "";
    });
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  String formatCheckInTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? "PM" : "AM";
    final minute = dt.minute.toString().padLeft(2, '0');
    return "$hour:$minute $ampm";
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} AM";

    final dateString =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} - ${_weekdayName(now.weekday)}";

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      bottomNavigationBar: EmployeeNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: 0,
              ),
              child: Row(
                children: [
                  Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Text(
              timeString,
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dateString,
              style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade400),
            ),
            const SizedBox(height: 60),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularPercentIndicator(
                          radius: 105,
                          lineWidth: 13,
                          percent: isCheckedIn ? percent : 0,
                          animation: true,
                          animateFromLastPercent: true,
                          circularStrokeCap: CircularStrokeCap.round,
                          backgroundColor: Colors.blueGrey.shade50,
                          progressColor:
                              isCheckedOut
                                  ? Colors.orange
                                  : isCheckedIn
                                  ? Colors.green
                                  : Colors.blue,
                          center: Container(
                            width: 158,
                            height: 158,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueGrey,
                                  blurRadius: 23,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (!isCheckedIn)
                                    isLoading
                                        ? const CircularProgressIndicator()
                                        : GestureDetector(
                                          onTap: _handleCheckInBox,
                                          child: Icon(
                                            Icons.fingerprint,
                                            color: Colors.blue,
                                            size: 58,
                                          ),
                                        ),
                                  if (isCheckedIn &&
                                      !isCheckedOut &&
                                      percent < 1)
                                    Icon(
                                      Icons.fingerprint,
                                      color: Colors.green,
                                      size: 54,
                                    ),
                                  if (isCheckedIn &&
                                      !isCheckedOut &&
                                      percent >= 1)
                                    isCheckOutLoading
                                        ? const CircularProgressIndicator()
                                        : GestureDetector(
                                          onTap: _handleCheckOutBox,
                                          child: Icon(
                                            Icons.logout,
                                            color: Colors.orange,
                                            size: 54,
                                          ),
                                        ),
                                  if (isCheckedIn && isCheckedOut)
                                    Icon(
                                      Icons.logout,
                                      color: Colors.orange,
                                      size: 54,
                                    ),
                                  const SizedBox(height: 8),
                                  if (!isCheckedIn)
                                    Text(
                                      "CHECK IN",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blue,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  if (isCheckedIn &&
                                      !isCheckedOut &&
                                      percent < 1)
                                    Text(
                                      "CHECK IN",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.green,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  if (isCheckedIn &&
                                      !isCheckedOut &&
                                      percent >= 1)
                                    Text(
                                      "CHECK OUT",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.orange,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  if (isCheckedIn && isCheckedOut)
                                    Text(
                                      "CHECKED OUT",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.orange,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  if (isCheckedIn && !isCheckedOut)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        checkInDisplay ?? "--:--",
                                        style: TextStyle(
                                          color: Colors.blueGrey.shade400,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  if (isCheckedIn && isCheckedOut)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        checkOutDisplay ?? "--:--",
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (isCheckedIn &&
                            minHalfDayText.isNotEmpty &&
                            !isCheckedOut)
                          Positioned(
                            bottom: -25,
                            child: Text(
                              minHalfDayText,
                              style: TextStyle(
                                color: Colors.blueGrey.shade400,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey,
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _attendanceItem(
                      Icons.login,
                      "Check In",
                      checkInDisplay ?? "--:--",
                    ),
                    _attendanceItem(
                      Icons.logout,
                      "Check Out",
                      checkOutDisplay ?? "--:--",
                      onTap:
                          (isCheckedIn && !isCheckedOut)
                              ? _handleCheckOutBox
                              : null,
                    ),
                    _attendanceItem(
                      Icons.access_time,
                      "Total Hours",
                      totalHours ?? "--:--",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _attendanceItem(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13),
          ),
        ],
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

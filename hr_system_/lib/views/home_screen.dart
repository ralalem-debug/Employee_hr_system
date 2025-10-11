import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_system_/models/attendance_model.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../controllers/attendance_controller.dart';
import 'employee_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AttendanceController controller = AttendanceController();

  AttendanceModel? attendance;
  bool isAtOffice = false;
  bool isLoading = false;

  Timer? apiTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    apiTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
  }

  @override
  void dispose() {
    apiTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    //  اقرأ الـ userId من التخزين الآمن
    final storage = const FlutterSecureStorage();
    final userId = await storage.read(key: 'user_id');

    if (userId == null) {
      print("⚠️ No user_id found in secure storage!");
      _showMsg("⚠️User ID not found. Please log in again.");
      setState(() => isLoading = false);
      return;
    }

    print("👤 Current userId: $userId");

    //  تحقق من وجود المستخدم داخل المكتب أولًا
    final present = await controller.isAtOffice(userId);

    //  إذا كان داخل المكتب، اجلب بيانات الحضور
    AttendanceModel? att;
    if (present) {
      att = await controller.getCheckInOutTime();
    }

    if (mounted) {
      setState(() {
        attendance = att;
        isAtOffice = present;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    final now = DateTime.now();
    final timeString =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final dateString =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} - ${_weekdayName(now.weekday)}";

    final canCheckIn =
        isAtOffice &&
        now.isAfter(DateTime(now.year, now.month, now.day, 8, 30)) &&
        (attendance?.checkInTime == null);

    final canCheckOut =
        isAtOffice &&
        attendance?.checkInTime != null &&
        _workedMinutes(attendance!.checkInTime!) >= 480 &&
        attendance?.checkOutTime == null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: EmployeeNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.05,
              vertical: h * 0.02,
            ),
            child: Column(
              children: [
                // الوقت والتاريخ
                _buildDateTimeCard(timeString, dateString),

                SizedBox(height: h * 0.04),

                _buildStatusCircle(w),

                SizedBox(height: h * 0.04),

                // بيانات الحضور
                if (attendance != null) _buildAttendanceInfo(w),

                SizedBox(height: h * 0.05),

                // أزرار Check-in / Check-out
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.login),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: h * 0.02),
                          backgroundColor:
                              canCheckIn ? Colors.teal.shade400 : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed:
                            canCheckIn
                                ? () async {
                                  final ok = await controller.doCheckIn();
                                  if (ok) {
                                    _showMsg("✅ Check-in recorded");
                                    await Future.delayed(
                                      const Duration(seconds: 1),
                                    );
                                    await _loadData(); // يعيد تحميل البيانات بعد أن يُسجل فعلاً
                                  } else {
                                    _showMsg("❌ Failed check-in");
                                  }
                                }
                                : null,
                        label: Text(
                          "Check-in",
                          style: TextStyle(fontSize: w * 0.04),
                        ),
                      ),
                    ),
                    SizedBox(width: w * 0.04),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: h * 0.02),
                          backgroundColor:
                              canCheckOut ? Colors.redAccent : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed:
                            canCheckOut
                                ? () async {
                                  final ok = await controller.doCheckOut();
                                  _showMsg(
                                    ok
                                        ? "✅ Check-out recorded"
                                        : "❌ Failed check-out",
                                  );
                                  _loadData();
                                }
                                : null,
                        label: Text(
                          "Check-out",
                          style: TextStyle(fontSize: w * 0.04),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeCard(String timeString, String dateString) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Text(
              timeString,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 6),
                Text(
                  dateString,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCircle(double w) {
    return CircularPercentIndicator(
      radius: w * 0.3,
      lineWidth: w * 0.04,
      percent: isAtOffice ? 1 : 0,
      animation: true,
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Colors.blueGrey.shade100,
      progressColor: isAtOffice ? Colors.teal.shade400 : Colors.redAccent,
      center:
          isLoading
              ? const CircularProgressIndicator()
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAtOffice ? Icons.emoji_events : Icons.location_off,
                    color: isAtOffice ? Colors.teal.shade400 : Colors.redAccent,
                    size: w * 0.15,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isAtOffice ? "At Office" : "Away",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.05,
                      color:
                          isAtOffice ? Colors.teal.shade400 : Colors.redAccent,
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildAttendanceInfo(double w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _infoColumn(
          Icons.login,
          attendance!.checkInTime ?? "--:--",
          "Check-in",
          w,
        ),
        _infoColumn(
          Icons.logout,
          attendance!.checkOutTime ?? "--:--",
          "Check-out",
          w,
        ),
        _infoColumn(
          Icons.timer,
          attendance!.totalHours ?? "--:--",
          "Total Hours",
          w,
        ),
      ],
    );
  }

  Widget _infoColumn(IconData icon, String value, String label, double w) {
    return Column(
      children: [
        Icon(icon, size: w * 0.08, color: Colors.blueAccent),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: w * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: w * 0.04, color: Colors.grey)),
      ],
    );
  }

  int _workedMinutes(String checkInTime) {
    final now = DateTime.now();
    final parts = checkInTime.split(":");
    if (parts.length < 2) return 0;
    final checkIn = DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 0,
    );
    return now.difference(checkIn).inMinutes;
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

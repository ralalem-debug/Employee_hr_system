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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final AttendanceController controller = AttendanceController();

  AttendanceModel? attendance;
  bool isLoading = false;
  Timer? apiTimer;
  Timer? liveTimer;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _checkStatus();

    // تحديث من API كل 30 ثانية
    apiTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkStatus(),
    );

    // تحديث العداد الحي كل دقيقة
    liveTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    apiTimer?.cancel();
    liveTimer?.cancel();
    _fadeController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _checkStatus() async {
    setState(() => isLoading = true);
    final status = await controller.checkAtOffice();
    if (mounted && status != null) {
      setState(() {
        attendance = status;
        isLoading = false;
      });
      _fadeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final dateString =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} - ${_weekdayName(now.weekday)}";

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      bottomNavigationBar: EmployeeNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Stack(
            children: [
              // خلفية دوائر
              Positioned(
                top: -100 + 20 * _bgController.value,
                left: -80,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.lightBlueAccent.withOpacity(0.08),
                ),
              ),
              Positioned(
                bottom: -120 - 20 * _bgController.value,
                right: -100,
                child: CircleAvatar(
                  radius: 140,
                  backgroundColor: Colors.blue.shade200.withOpacity(0.07),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    const Padding(padding: EdgeInsets.all(20)),

                    // الوقت والتاريخ
                    Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
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
                    ),
                    const SizedBox(height: 70),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: CircularPercentIndicator(
                        radius: 110,
                        lineWidth: 14,
                        percent:
                            _calculateWorkProgress() %
                            1, // 🔹 يدور ويعيد نفسه بعد كل لفة
                        animation: true,
                        circularStrokeCap: CircularStrokeCap.round,
                        backgroundColor: Colors.blueGrey.shade100,

                        // 🔹 اللون يتغير بعد 8 ساعات
                        progressColor:
                            (_calculateWorkProgress() >= 1)
                                ? Colors
                                    .redAccent // Overtime
                                : Colors.teal.shade400, // Normal time

                        center: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child:
                                isLoading
                                    ? const CircularProgressIndicator()
                                    : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          (attendance?.isAtOffice ?? false)
                                              ? (_calculateWorkProgress() >= 1
                                                  ? Icons
                                                      .lock_clock // بعد 8 ساعات
                                                  : Icons
                                                      .emoji_events) // قبل 8 ساعات
                                              : Icons.location_off,
                                          color:
                                              (_calculateWorkProgress() >= 1)
                                                  ? Colors.redAccent
                                                  : Colors.teal.shade400,
                                          size: 60,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          (attendance?.isAtOffice ?? false)
                                              ? (_calculateWorkProgress() >= 1
                                                  ? "Overtime"
                                                  : "At Office")
                                              : "Away",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color:
                                                (_calculateWorkProgress() >= 1)
                                                    ? Colors.redAccent
                                                    : Colors.teal.shade400,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 90),

                    // 3 أعمدة (CheckIn, LastUpdated, MinutesOnline)
                    if (attendance != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 🕒 Check-in
                          Column(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 32,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                attendance!.checkInAt != null
                                    ? "${attendance!.checkInAt!.hour.toString().padLeft(2, '0')}:${attendance!.checkInAt!.minute.toString().padLeft(2, '0')}"
                                    : "--:--",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "checkInAt",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),

                          // 🔄 Last Updated
                          Column(
                            children: [
                              const Icon(
                                Icons.update,
                                size: 32,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                attendance!.lastUpdated != null
                                    ? "${attendance!.lastUpdated!.hour.toString().padLeft(2, '0')}:${attendance!.lastUpdated!.minute.toString().padLeft(2, '0')}"
                                    : "--:--",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "lastUpdated",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),

                          // ⏳ Minutes Online (حي)
                          Column(
                            children: [
                              const Icon(
                                Icons.timelapse,
                                size: 32,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                attendance?.liveMinutesOnline ?? "--:--",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "minutesOnline",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _calculateWorkProgress() {
    if (attendance?.checkInAt == null) return 0;

    final diff = DateTime.now().difference(attendance!.checkInAt!);
    final totalMinutes = diff.inMinutes;

    // 480 دقيقة = 8 ساعات
    return totalMinutes / 480; // ممكن يصير > 1
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

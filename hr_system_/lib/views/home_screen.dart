import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../controllers/attendance_controller.dart';
import 'employee_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final AttendanceController controller = AttendanceController();

  bool isAtOffice = false;
  bool isLoading = false;
  Timer? timer;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _checkStatus();

    timer = Timer.periodic(const Duration(seconds: 30), (_) => _checkStatus());

    // Animation for fade
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    // Animation for background circles
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    timer?.cancel();
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
    if (mounted) {
      setState(() {
        isAtOffice = status;
        isLoading = false;
      });
      _fadeController.forward(from: 0); // Re-animate status change
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
      backgroundColor: Colors.white, // ✅ خلفية بيضا بالكامل
      bottomNavigationBar: EmployeeNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Stack(
            children: [
              // ===== دوائر خفيفة متحركة (أزرق فاتح شفاف) =====
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

              // ===== المحتوى =====
              SafeArea(
                child: Column(
                  children: [
                    // العنوان
                    Padding(padding: const EdgeInsets.all(20)),

                    // الوقت والتاريخ
                    Card(
                      color: Colors.white,
                      elevation: 0, // clean look
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
                    const SizedBox(height: 100),

                    // دائرة الحالة
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: CircularPercentIndicator(
                        radius: 110,
                        lineWidth: 14,
                        percent: isAtOffice ? 1 : 0,
                        animation: true,
                        circularStrokeCap: CircularStrokeCap.round,
                        backgroundColor: Colors.blueGrey.shade100,
                        progressColor:
                            isAtOffice
                                ? Colors.greenAccent.shade700
                                : Colors.redAccent,
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
                                          isAtOffice
                                              ? Icons.emoji_events
                                              : Icons.location_off,
                                          color:
                                              isAtOffice
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                          size: 60,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          isAtOffice ? "At Office" : "Away",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color:
                                                isAtOffice
                                                    ? Colors.green.shade700
                                                    : Colors.redAccent,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
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

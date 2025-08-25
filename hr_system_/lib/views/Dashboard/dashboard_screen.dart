import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/calender_holiday_controller.dart';
import 'package:hr_system_/models/calendar_holiday_model.dart';
import 'package:hr_system_/views/Dashboard/break_screen.dart';
import 'package:hr_system_/views/Dashboard/complaints_list_screen.dart';
import 'package:hr_system_/views/Dashboard/leave_list_screen.dart';
import 'package:hr_system_/views/Dashboard/list_note_screen.dart';
import 'package:hr_system_/views/Dashboard/overtime_list_screen.dart';
import 'package:hr_system_/views/Dashboard/partial_leave_list_screen.dart';
import 'package:hr_system_/views/Dashboard/leave_request_page.dart';
import 'package:hr_system_/views/Dashboard/partial_leave_request_view.dart';
import 'package:hr_system_/views/Dashboard/resignation_request_screen.dart'
    show ResignationRequestScreen;
import 'package:hr_system_/views/Dashboard/salary_advance_list_screen.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../employee_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1;

  // Calendar
  bool isLoadingEvents = true;
  Map<DateTime, List<HolidayEventModel>> eventsMap = {};
  final HolidayEventsController eventsController = HolidayEventsController();

  // Performance
  bool isLoadingPerformance = true;
  int totalScore = 0;
  int projects = 0;
  int attendance = 0;
  int leaves = 0;
  int lateness = 0;

  @override
  void initState() {
    super.initState();
    _loadCalendarEvents();
    _fetchPerformance();
  }

  Future<void> _fetchPerformance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 🔹 نفس المفاتيح اللي تخزنها في LoginController
      final token =
          prefs.getString('auth_token') ?? prefs.getString('token') ?? '';
      final rawEmployeeId =
          prefs.getString('employee_id') ?? prefs.getString('employeeId') ?? '';

      if (token.isEmpty || rawEmployeeId.isEmpty) {
        setState(() => isLoadingPerformance = false);
        return;
      }

      final employeeId = Uri.encodeComponent(rawEmployeeId);
      final url = Uri.parse(
        'http://192.168.1.131:5005/api/employee/get-performance/$employeeId',
      );

      final res = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        setState(() {
          totalScore =
              (body['totalScore'] ?? 0) is num
                  ? (body['totalScore'] as num).toInt()
                  : 0;
          projects =
              (body['projects'] ?? 0) is num
                  ? (body['projects'] as num).toInt()
                  : 0;
          attendance =
              (body['attendance'] ?? 0) is num
                  ? (body['attendance'] as num).toInt()
                  : 0;
          leaves =
              (body['leaves'] ?? 0) is num
                  ? (body['leaves'] as num).toInt()
                  : 0;
          lateness =
              (body['lateness'] ?? 0) is num
                  ? (body['lateness'] as num).toInt()
                  : 0;

          totalScore = totalScore.clamp(0, 100);
          isLoadingPerformance = false;
        });
      } else {
        setState(() => isLoadingPerformance = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingPerformance = false);
      debugPrint("Error fetching performance: $e");
    }
  }

  Future<void> _loadCalendarEvents() async {
    setState(() => isLoadingEvents = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('auth_token');
      if (jwtToken == null) {
        setState(() => isLoadingEvents = false);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please login again!')));
        return;
      }
      List<HolidayEventModel> events = await eventsController.fetchEvents(
        jwtToken,
      );
      Map<DateTime, List<HolidayEventModel>> eventMap = {};
      for (var event in events) {
        final key = DateTime(event.date.year, event.date.month, event.date.day);
        eventMap.putIfAbsent(key, () => []).add(event);
      }
      setState(() {
        eventsMap = eventMap;
        isLoadingEvents = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingEvents = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading calendar events: $e')),
      );
    }
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showCalendarDialog() {
    final parentContext = context;
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 14,
          child:
              isLoadingEvents
                  ? const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : Container(
                    padding: const EdgeInsets.all(14),
                    child: SizedBox(
                      height: 300,
                      child: TableCalendar<HolidayEventModel>(
                        firstDay: DateTime.utc(2022, 1, 1),
                        lastDay: DateTime.utc(2026, 12, 31),
                        focusedDay: DateTime.now(),
                        calendarFormat: CalendarFormat.month,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextFormatter:
                              (date, locale) =>
                                  "${_monthName(date.month).toUpperCase()}, ${date.year}",
                          titleTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade700,
                            letterSpacing: 1.3,
                          ),
                          leftChevronIcon: const Icon(
                            Icons.chevron_left,
                            color: Colors.blueGrey,
                            size: 22,
                          ),
                          rightChevronIcon: const Icon(
                            Icons.chevron_right,
                            color: Colors.blueGrey,
                            size: 22,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Colors.blueGrey.shade400,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 1.7,
                          ),
                          weekendStyle: TextStyle(
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 1.7,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.blue.shade200,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: const BoxDecoration(
                            color: Color(0xFFFFA726),
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: TextStyle(
                            color: Colors.blueGrey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          weekendTextStyle: TextStyle(
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                          outsideDaysVisible: false,
                        ),
                        rowHeight: 34,
                        daysOfWeekHeight: 28,
                        eventLoader: (day) {
                          final key = DateTime(day.year, day.month, day.day);
                          return eventsMap[key] ?? [];
                        },
                        selectedDayPredicate: (day) => false,
                        onDaySelected: (day, focusedDay) {
                          Navigator.of(context).pop();
                          Future.delayed(const Duration(milliseconds: 200), () {
                            _showDayEventsDialog(day, parentContext);
                          });
                        },
                        locale: "en",
                      ),
                    ),
                  ),
        );
      },
    );
  }

  void _showDayEventsDialog(DateTime day, BuildContext parentContext) {
    final key = DateTime(day.year, day.month, day.day);
    final events = eventsMap[key] ?? [];
    if (events.isEmpty) return;

    showDialog(
      context: parentContext,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Events on ${day.toString().substring(0, 10)}"),
            content: SizedBox(
              width: 300,
              child: ListView(
                shrinkWrap: true,
                children:
                    events
                        .map(
                          (e) => ListTile(
                            leading: Icon(
                              e.type == "Holiday"
                                  ? Icons.celebration
                                  : Icons.event_note,
                              color:
                                  e.type == "Holiday"
                                      ? Colors.deepOrange
                                      : Colors.blue,
                            ),
                            title: Text(e.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.type),
                                if (e.status != null)
                                  Text('Status: ${e.status!}'),
                                if (e.timeRange != null)
                                  Text('Time: ${e.timeRange!}'),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(parentContext),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
    );
  }

  void _showLeaveOptionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 12,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 36,
            vertical: 220,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _leaveOptionButton(
                  label: 'Partial Day Leave Request',
                  icon: Icons.access_time,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PartialLeaveRequestView(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _leaveOptionButton(
                  label: 'Partial Day Leave List',
                  icon: Icons.list_alt,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PartialLeaveListScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _leaveOptionButton(
                  label: 'Leave Request',
                  icon: Icons.note_add,
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('auth_token');
                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please login again!')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 100));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LeaveRequestPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _leaveOptionButton(
                  label: 'Request Leave List',
                  icon: Icons.history,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LeavesListView()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _leaveOptionButton({
    required String label,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color.fromARGB(255, 29, 83, 199),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double percent = (totalScore / 100).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _showCalendarDialog,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.shade50,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.07),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          size: 28,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // دائرة الأداء
                Center(
                  child:
                      isLoadingPerformance
                          ? const CircularProgressIndicator()
                          : CircularPercentIndicator(
                            radius: 86,
                            lineWidth: 18,
                            percent: percent,
                            animation: true,
                            animationDuration: 1200,
                            startAngle: 180,
                            circularStrokeCap: CircularStrokeCap.round,
                            backgroundColor: Colors.grey[200]!,
                            linearGradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.green.shade400,
                                Colors.orange.shade400,
                                Colors.red.shade400,
                                Colors.blue.shade400,
                              ],
                              stops: const [0.0, 0.45, 0.75, 0.9, 1.0],
                            ),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$totalScore%",
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade800,
                                  ),
                                ),
                                Text(
                                  "Performance",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.blueGrey[600],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),

                // const SizedBox(height: 16),

                // // كروت القيم التفصيلية
                // if (!isLoadingPerformance)
                //   Row(
                //     children: [
                //       Expanded(
                //         child: _metricCard(
                //           title: "Projects",
                //           value: projects,
                //           borderColor: Colors.blue.shade300,
                //           icon: Icons.work_outline,
                //           iconColor: Colors.blue.shade600,
                //         ),
                //       ),
                //       const SizedBox(width: 12),
                //       Expanded(
                //         child: _metricCard(
                //           title: "Attendance",
                //           value: attendance,
                //           borderColor: Colors.green.shade300,
                //           icon: Icons.how_to_reg_outlined,
                //           iconColor: Colors.green.shade700,
                //         ),
                //       ),
                //     ],
                //   ),
                // if (!isLoadingPerformance) const SizedBox(height: 12),
                // if (!isLoadingPerformance)
                //   Row(
                //     children: [
                //       Expanded(
                //         child: _metricCard(
                //           title: "Leaves",
                //           value: leaves,
                //           borderColor: Colors.orange.shade300,
                //           icon: Icons.event_busy_outlined,
                //           iconColor: Colors.orange.shade700,
                //         ),
                //       ),
                //       const SizedBox(width: 12),
                //       Expanded(
                //         child: _metricCard(
                //           title: "Lateness",
                //           value: lateness,
                //           borderColor: Colors.red.shade300,
                //           icon: Icons.access_time,
                //           iconColor: Colors.red.shade600,
                //         ),
                //       ),
                //     ],
                //   ),
                const SizedBox(height: 22),

                // شبكة الميزات
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.07),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 8, bottom: 12),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 18,
                    children: [
                      _featureButton(
                        Icons.shield_outlined,
                        "Note",
                        Colors.blue.shade600,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NotesListScreen(),
                            ),
                          );
                        },
                      ),
                      _featureButton(
                        Icons.warning_amber_outlined,
                        "Complaint",
                        Colors.amber.shade700,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ComplaintsListScreen(),
                            ),
                          );
                        },
                      ),
                      _featureButton(
                        Icons.work_outline,
                        "Resignation",
                        Colors.deepOrange.shade400,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ResignationRequestScreen(),
                            ),
                          );
                        },
                      ),
                      _featureButton(
                        Icons.event_note,
                        "Leave",
                        Colors.indigo.shade600,
                        onTap: _showLeaveOptionsDialog,
                      ),
                      _featureButton(
                        Icons.av_timer,
                        "Over time",
                        Colors.blueGrey.shade700,
                        onTap: () {
                          Get.to(() => OvertimeListScreen());
                        },
                      ),
                      _featureButton(
                        Icons.attach_money,
                        "SalaryAdvance",
                        Colors.green.shade700,
                        onTap: () {
                          Get.to(() => SalaryAdvanceListScreen());
                        },
                      ),
                      _featureButton(
                        Icons.timelapse,
                        "Break In",
                        Colors.cyan.shade600,
                        onTap: () {
                          Get.to(() => BreakScreen());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: EmployeeNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  // Widget _metricCard({
  //   required String title,
  //   required int value,
  //   required Color borderColor,
  //   required IconData icon,
  //   required Color iconColor,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: borderColor.withOpacity(0.35), width: 1),
  //       boxShadow: [
  //         BoxShadow(
  //           color: borderColor.withOpacity(0.10),
  //           blurRadius: 12,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             gradient: LinearGradient(
  //               colors: [
  //                 iconColor.withOpacity(0.14),
  //                 iconColor.withOpacity(0.07),
  //               ],
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //             ),
  //           ),
  //           padding: const EdgeInsets.all(10),
  //           child: Icon(icon, color: iconColor, size: 24),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 title,
  //                 style: TextStyle(
  //                   color: Colors.blueGrey.shade700,
  //                   fontSize: 13.5,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 "$value",
  //                 style: TextStyle(
  //                   color: Colors.blueGrey.shade900,
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _featureButton(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.14), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 9,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.14), color.withOpacity(0.07)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: color, size: 27),
            ),
            const SizedBox(height: 7),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.blueGrey.shade900,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.2,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hr_system_/controllers/Dashboard/partial_leave_list_controller.dart';
import 'package:hr_system_/models/Dashboard/partial_leave_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../employee_nav_bar.dart';

class PartialLeaveListScreen extends StatefulWidget {
  const PartialLeaveListScreen({super.key});

  @override
  State<PartialLeaveListScreen> createState() => _LeavesListViewState();
}

class _LeavesListViewState extends State<PartialLeaveListScreen> {
  int _selectedIndex = 1;
  late PartialLeaveListController controller;
  Future<List<PartialDayLeaveModel>>? futureLeaves;
  String? jwtToken;

  String selectedSort = 'leaveDate-desc';

  final sortOptions = {
    'leaveDate-asc': 'Leave Date ↑',
    'leaveDate-desc': 'Leave Date ↓',
    'requestStatus-asc': 'Status ↑',
    'requestStatus-desc': 'Status ↓',
  };

  // Ticker لتحديث العدادات كل ثانية
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    controller = PartialLeaveListController();
    _loadTokenAndLeaves();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {}); // يحدّث الـ UI لعرض العداد
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ================= Helpers =================
  String _fmt2(int n) => n.toString().padLeft(2, '0');

  String _formatNowHHmm() {
    final now = DateTime.now();
    return "${_fmt2(now.hour)}:${_fmt2(now.minute)}";
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return "${_fmt2(h)}:${_fmt2(m)}:${_fmt2(s)}"; // HH:mm:ss
  }

  DateTime? _parseStartDateTime(PartialDayLeaveModel leave) {
    try {
      if (leave.leaveStartTime == null || leave.leaveStartTime!.isEmpty)
        return null;

      // leaveDate: "YYYY-MM-DD", leaveStartTime: "HH:mm" أو "HH:mm:ss"
      final date = leave.leaveDate.trim();
      final time = leave.leaveStartTime!.trim();

      final partsD = date.split('-'); // [YYYY, MM, DD]
      final partsT = time.split(':'); // [HH, mm, (ss?)]

      final year = int.parse(partsD[0]);
      final month = int.parse(partsD[1]);
      final day = int.parse(partsD[2]);
      final hour = int.parse(partsT[0]);
      final minute = int.parse(partsT[1]);
      final second = partsT.length > 2 ? int.parse(partsT[2]) : 0;

      return DateTime(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
  }

  // ================ Data =====================
  Future<void> _loadTokenAndLeaves() async {
    final prefs = await SharedPreferences.getInstance();
    jwtToken = prefs.getString('auth_token');
    _refreshLeaves();
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _refreshLeaves() async {
    final parts = selectedSort.split('-');
    final sortBy = parts[0];
    final order = parts[1];
    setState(() {
      futureLeaves = controller.fetchLeaves(
        jwtToken: jwtToken,
        sortBy: sortBy,
        order: order,
      );
    });
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        String tempSelection = selectedSort;
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: const Text("Sort Options"),
          content: DropdownButtonFormField<String>(
            value: tempSelection,
            dropdownColor: Colors.white,
            items:
                sortOptions.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
            onChanged: (val) {
              if (val != null) tempSelection = val;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedSort = tempSelection;
                  _refreshLeaves();
                });
                Navigator.pop(ctx);
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString =
        "${_fmt2(now.hour)}:${_fmt2(now.minute)} ${now.hour >= 12 ? "PM" : "AM"}";
    final dateString =
        "${now.year}-${_fmt2(now.month)}-${_fmt2(now.day)} - ${_weekdayName(now.weekday)}";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              timeString,
              style: TextStyle(
                fontSize: 35,
                color: Colors.blueGrey.shade700,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateString,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.sort, color: Colors.blueGrey.shade600),
                    tooltip: "Sort",
                    onPressed: _showSortDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  futureLeaves == null
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                        onRefresh: _refreshLeaves,
                        child: FutureBuilder<List<PartialDayLeaveModel>>(
                          future: futureLeaves,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  "Error: ${snapshot.error}",
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                child: Text(
                                  "No leaves found.",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 17,
                                  ),
                                ),
                              );
                            } else {
                              final leaves = snapshot.data!;
                              return ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                itemCount: leaves.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final leave = leaves[index];
                                  return _leaveCard(leave);
                                },
                              );
                            }
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EmployeeNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _leaveCard(PartialDayLeaveModel leave) {
    final status = leave.requestStatus.trim().toLowerCase();
    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case "approved":
        statusColor = Colors.green.shade500;
        statusIcon = Icons.check_circle;
        break;
      case "pending":
        statusColor = Colors.orange.shade600;
        statusIcon = Icons.hourglass_empty_rounded;
        break;
      case "rejected":
        statusColor = Colors.red.shade400;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info_outline;
    }

    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(13),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: Colors.blue.shade50,
              child: Icon(
                Icons.av_timer,
                color: Colors.blue.shade600,
                size: 27,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Partial Day Leave",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.5,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Planned window
                  Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 15,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        leave.leaveDate,
                        style: TextStyle(
                          color: Colors.blueGrey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "${leave.fromTime} - ${leave.toTime}",
                        style: TextStyle(
                          color: Colors.blueGrey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 15,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        leave.leaveEndTime != null
                            ? "Total: ${leave.hours} • Left at ${leave.leaveEndTime}"
                            : "Total: ${leave.hours}",
                        style: TextStyle(
                          color: Colors.blueGrey.shade500,
                          fontSize: 13.7,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.message,
                        size: 15,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          leave.reason.isEmpty ? "No reason" : leave.reason,
                          style: TextStyle(
                            color: Colors.blueGrey.shade500,
                            fontSize: 13.7,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  // Status line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 19),
                      const SizedBox(width: 4),
                      Text(
                        leave.requestStatus,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                          fontSize: 14.5,
                        ),
                      ),
                      if (status == "pending")
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.cancel,
                              size: 15,
                              color: Colors.red,
                            ),
                            label: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 13.5,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              minimumSize: const Size(0, 28),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Cancel Request'),
                                      content: const Text(
                                        'Are you sure you want to cancel this leave request?',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('No'),
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                        ),
                                        TextButton(
                                          child: const Text('Yes'),
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                final success = await controller
                                    .cancelPartialDayLeave(
                                      leave.partialLeaveId,
                                      jwtToken ?? '',
                                    );
                                if (success) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Leave cancelled successfully!',
                                        ),
                                      ),
                                    );
                                  }
                                  _refreshLeaves();
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to cancel leave'),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Actual start/end/duration + Running counter
                  if (leave.leaveStartTime != null ||
                      leave.leaveEndTime != null ||
                      (leave.actualLeaveDuration ?? '').isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (leave.leaveStartTime != null)
                          Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                size: 15,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Start Time: ${leave.leaveStartTime}",
                                style: TextStyle(
                                  color: Colors.blueGrey.shade600,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),

                        // Running timer while in progress
                        if (leave.hasStarted && !leave.hasEnded)
                          Builder(
                            builder: (_) {
                              final startDT = _parseStartDateTime(leave);
                              Duration? elapsed;
                              if (startDT != null) {
                                elapsed = DateTime.now().difference(startDT);
                                if (elapsed.isNegative) elapsed = Duration.zero;
                              }
                              return Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 15,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Running: ${elapsed != null ? _formatDuration(elapsed) : '--:--:--'}",
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                        if (leave.leaveEndTime != null)
                          Row(
                            children: [
                              Icon(
                                Icons.stop_circle_outlined,
                                size: 15,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "End Time: ${leave.leaveEndTime}",
                                style: TextStyle(
                                  color: Colors.blueGrey.shade600,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),

                        if ((leave.actualLeaveDuration ?? '').isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.hourglass_bottom,
                                size: 15,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Actual: ${leave.actualLeaveDuration}",
                                style: TextStyle(
                                  color: Colors.blueGrey.shade600,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                  const SizedBox(height: 8),

                  // Start / End buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (leave.requestStatus.trim().toLowerCase() ==
                              "approved" &&
                          !leave.hasStarted)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text("Start"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 32),
                          ),
                          onPressed: () async {
                            try {
                              final startedAt = await controller
                                  .startPartialDayLeave(
                                    leave.partialLeaveId,
                                    jwtToken ?? '',
                                  );

                              // تفاؤلي: فعّل End فورًا
                              setState(() {
                                leave.leaveStartTime =
                                    startedAt ?? _formatNowHHmm(); // "HH:mm"
                              });

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Partial leave started'),
                                  ),
                                );
                              }

                              // لا نعمل refresh الآن حتى لا نخسر العداد لو الـ list ما ترجع start
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to start: $e'),
                                  ),
                                );
                              }
                            }
                          },
                        ),

                      if (leave.requestStatus.trim().toLowerCase() ==
                          "approved")
                        const SizedBox(width: 8),

                      if (leave.requestStatus.trim().toLowerCase() ==
                              "approved" &&
                          leave.hasStarted &&
                          !leave.hasEnded)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.stop, size: 16),
                          label: const Text("End"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 32),
                          ),
                          onPressed: () async {
                            try {
                              // احسب المدة الفعلية محليًا قبل الرفرش
                              final startDT = _parseStartDateTime(leave);
                              String? durationString;
                              if (startDT != null) {
                                final diff = DateTime.now().difference(startDT);
                                durationString = _formatDuration(diff);
                              }

                              final ok = await controller.endPartialDayLeave(
                                leave.partialLeaveId,
                                jwtToken ?? '',
                              );
                              if (ok) {
                                setState(() {
                                  leave.leaveEndTime =
                                      _formatNowHHmm(); // "HH:mm"
                                  if (durationString != null) {
                                    leave.actualLeaveDuration =
                                        durationString; // "HH:mm:ss"
                                  }
                                });

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Partial leave ended'),
                                    ),
                                  );
                                }

                                // الآن رجّع حمّل من السيرفر لتثبيت النتيجة
                                await _refreshLeaves();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to end: $e')),
                                );
                              }
                            }
                          },
                        ),

                      if (leave.hasEnded)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Chip(
                            label: Text(
                              (leave.actualLeaveDuration ?? '').isNotEmpty
                                  ? "Completed • ${leave.actualLeaveDuration}"
                                  : "Completed",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/Dashboard/breaks_controller.dart';
import 'package:hr_system_/models/Dashboard/breaks_model.dart';
import 'dart:async';

class BreakTimerWidget extends StatefulWidget {
  final BreakModel breakModel;
  final String breakReportId;
  final Duration? initialDuration;

  BreakTimerWidget({
    required this.breakModel,
    required this.breakReportId,
    this.initialDuration,
  });

  @override
  State<BreakTimerWidget> createState() => _BreakTimerWidgetState();
}

class _BreakTimerWidgetState extends State<BreakTimerWidget> {
  late Duration duration;
  Timer? timer;
  bool breakEnded = false;
  bool showAlert = false;
  bool isEnding = false;
  String? breakDuration;

  @override
  void initState() {
    super.initState();
    duration =
        widget.initialDuration ?? _parseDuration(widget.breakModel.duration);
    startTimer();
  }

  Duration _parseDuration(String str) {
    final parts = str.split(":").map(int.parse).toList();
    if (parts.length == 3) {
      return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
    } else if (parts.length == 2) {
      return Duration(minutes: parts[0], seconds: parts[1]);
    } else if (parts.length == 1) {
      return Duration(seconds: parts[0]);
    } else {
      return Duration.zero;
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (duration.inSeconds > 0 && !breakEnded) {
        setState(() {
          duration -= Duration(seconds: 1);

          // التنبيه عند آخر 10 ثواني
          if (duration.inSeconds == 10 && !showAlert) {
            showAlert = true;
            _showAlert();
          }
        });
      } else {
        timer?.cancel();
        if (!breakEnded) _autoEndBreak();
      }
    });
  }

  Future<void> _showAlert() async {
    // يظهر تنبيه عند العشر ثواني الأخيرة
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            title: Text("Attention"),
            content: Text(
              "Only 10 seconds left! Please end your break now, otherwise you will be exited automatically.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _manualEndBreak();
                },
                child: Text("End Break Now"),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  void _manualEndBreak() async {
    if (isEnding) return;
    isEnding = true;
    if (!mounted) return;
    setState(() {
      breakEnded = true;
    });
    final controller = Get.find<BreakController>();
    final res = await controller.endBreak(widget.breakReportId);
    if (!mounted) return;
    setState(() {
      breakDuration = res ?? "";
    });
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _autoEndBreak() async {
    if (isEnding) return;
    isEnding = true;
    if (!mounted) return;
    setState(() {
      breakEnded = true;
    });
    final controller = Get.find<BreakController>();
    final res = await controller.endBreak(widget.breakReportId);
    if (!mounted) return;
    setState(() {
      breakDuration = res ?? "";
    });
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timeStr =
        "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: const Color(0xfff8fbff),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 150),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            margin: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.breakModel.name.toLowerCase().contains("lunch")
                        ? Icons.lunch_dining
                        : Icons.mosque,
                    size: 64,
                    color: Colors.blue[700],
                  ),
                  SizedBox(height: 20),
                  Text(
                    breakEnded ? "Break ended!" : "You're now on a",
                    style: TextStyle(
                      fontSize: 16.5,
                      color: Colors.blueGrey[700],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    breakEnded && breakDuration != null
                        ? "Your break duration: $breakDuration"
                        : "${_durationToText(widget.initialDuration ?? _parseDuration(widget.breakModel.duration))} minute ${widget.breakModel.name.toLowerCase()} ",
                    style: TextStyle(
                      fontSize: 18.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Work duration timer is paused",
                    style: TextStyle(fontSize: 13.2, color: Colors.grey[500]),
                  ),
                  SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 38),
                    child: Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 48,
                        letterSpacing: 2.4,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          breakEnded
                              ? () => Navigator.pop(context)
                              : _manualEndBreak,
                      child: Text(
                        breakEnded ? "Back" : "Break Out",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _durationToText(Duration duration) {
    if (duration.inHours > 0) {
      return "${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}";
    }
    return duration.inMinutes.toString();
  }
}

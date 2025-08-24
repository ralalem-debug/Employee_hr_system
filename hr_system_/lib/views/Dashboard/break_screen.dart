import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/Dashboard/breaks_controller.dart';
import 'package:hr_system_/models/Dashboard/breaks_model.dart';
import 'package:hr_system_/views/Dashboard/break_timer_widget.dart';
import 'package:hr_system_/views/employee_nav_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';

class BreakScreen extends StatelessWidget {
  final BreakController controller = Get.put(BreakController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f8fd),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        }
        if (controller.breaks.isEmpty) {
          return Center(child: Text("No breaks available"));
        }
        return SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    _performanceWidget(),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 13.0),
                      child: Text(
                        "Select Break Type",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.5,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                    ...controller.breaks
                        .map((br) => _breakButton(context, br))
                        .toList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: EmployeeNavBar(currentIndex: 1),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _performanceWidget() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 38.0),
    child: Column(
      children: [
        CircularPercentIndicator(
          radius: 90,
          lineWidth: 20,
          percent: 0.75,
          animation: true,
          animationDuration: 1100,
          startAngle: 180,
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: Colors.blueGrey.shade50,
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
                "75%",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Performance",
                style: TextStyle(
                  fontSize: 16.5,
                  color: Colors.blueGrey[600],
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _breakButton(BuildContext context, BreakModel breakModel) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30),
    child: Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 5,
      shadowColor: Colors.blue.shade100.withOpacity(0.18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.blue.shade50, width: 1.6),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final remaining = await controller.getRemainingTime(
              breakModel.breakId,
            );

            if (remaining == null || remaining.inSeconds <= 10) {
              Get.snackbar(
                "Not Allowed",
                "You only have 00:00:05 left for this break, which is too short to start.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red[100],
                colorText: Colors.red[900],
                duration: const Duration(seconds: 4),
                margin: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              );
              return;
            }

            final breakReportId = await controller.startBreak(
              breakModel.breakId,
            );
            if (breakReportId != null) {
              Get.to(
                () => BreakTimerWidget(
                  breakModel: breakModel,
                  breakReportId: breakReportId,
                  initialDuration: remaining,
                ),
              );
            } else {
              Get.snackbar(
                "Error",
                "Couldn't start break. Try again!",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red[100],
                colorText: Colors.red[900],
                duration: const Duration(seconds: 3),
                margin: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    breakModel.name.toLowerCase().contains("lunch")
                        ? Icons.lunch_dining
                        : Icons.mosque,
                    color: Colors.blue[700],
                    size: 33,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    breakModel.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.5,
                      color: Colors.blue[900],
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.blue[200],
                  size: 21,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

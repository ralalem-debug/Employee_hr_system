import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/jobs_controller.dart';
import 'package:hr_system_/views/Nonemployees/custom_nav_bar.dart';
import 'package:hr_system_/views/Nonemployees/job_card.dart';

class NonEmployeeHomeScreen extends StatefulWidget {
  const NonEmployeeHomeScreen({super.key});

  @override
  State<NonEmployeeHomeScreen> createState() => _NonEmployeeHomeScreenState();
}

class _NonEmployeeHomeScreenState extends State<NonEmployeeHomeScreen> {
  final JobsController _c = Get.put(JobsController());

  @override
  void initState() {
    super.initState();
    _c.fetchJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 83, 176, 252),
                        Color.fromARGB(255, 0, 77, 155),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "👋 Welcome Back,",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Ready to find your next Job?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Jobs Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.work_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        "Recommended Jobs",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (_c.isLoading.value)
                  const Center(child: CircularProgressIndicator())
                else if (_c.jobs.isEmpty)
                  const Center(child: Text("No jobs available right now."))
                else
                  SizedBox(
                    height: 260,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder:
                          (_, i) => SizedBox(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: JobCard(
                              job: _c.jobs[i],
                              onApply: () => _c.applyToJob(_c.jobs[i].jobId),
                              isApplied: _c.appliedJobIds.contains(
                                _c.jobs[i].jobId,
                              ),
                            ),
                          ),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: _c.jobs.length,
                    ),
                  ),

                const SizedBox(height: 30),

                // 🔹 Upcoming Interview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.calendar_month, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        "Upcoming Interview",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Senior Accountant Interview",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Icon(Icons.event, size: 18, color: Colors.blue),
                            SizedBox(width: 6),
                            Text("4.09.2025, THU"),
                          ],
                        ),
                        Row(
                          children: const [
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 6),
                            Text("9:00 AM"),
                          ],
                        ),
                        Row(
                          children: const [
                            Icon(
                              Icons.videocam_outlined,
                              size: 18,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 6),
                            Text("Google Meet"),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text("Contact HR"),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text("Confirm Attendance"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/jobs_controller.dart';
import 'package:hr_system_/views/Nonemployees/custom_nav_bar.dart';
import 'package:hr_system_/views/Nonemployees/job_card.dart'; // ✅ استدعاء الويجت الجديد

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  "HELLO",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "ARE YOU READY TO FIND YOUR JOB?",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 18),

                // Jobs header
                Row(
                  children: [
                    Container(width: 4, height: 22, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      "Jobs Available",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_c.isLoading.value)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_c.jobs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text("No jobs available right now."),
                  )
                else
                  Column(
                    children:
                        _c.jobs
                            .map(
                              (job) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: JobCard(
                                  job: job,
                                  onApply: () => _c.applyToJob(job.jobId),
                                  isApplied: _c.appliedJobIds.contains(
                                    job.jobId,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),

                const SizedBox(height: 24),

                // Upcoming Interview (placeholder – اربطها لاحقًا من API لو موجود)
                Row(
                  children: [
                    Container(width: 4, height: 22, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      "Upcoming Interview",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "After The HR review your CV and test results they booked this interview so make sure you attended",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xffe7f0fb),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _rowIconText(Icons.event, "4.09.2025, THU"),
                      _rowIconText(Icons.access_time, "9:00 AM"),
                      _rowIconText(Icons.videocam_outlined, "Google Meet"),
                      _rowIconText(Icons.link, "www.Linkqadi.com//"),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                            ),
                            child: const Text("Contact"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                            ),
                            child: const Text("Confirm Your Attendance"),
                          ),
                        ],
                      ),
                    ],
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

  Widget _rowIconText(IconData i, String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Icon(i, size: 18, color: Colors.black87),
        const SizedBox(width: 8),
        Flexible(child: Text(t)),
      ],
    ),
  );
}

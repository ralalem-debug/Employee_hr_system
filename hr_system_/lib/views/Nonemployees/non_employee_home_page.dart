import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/jobs_controller.dart';
import 'package:hr_system_/views/Nonemployees/custom_nav_bar.dart';
import 'package:hr_system_/views/Nonemployees/job_card.dart';
import 'package:url_launcher/url_launcher.dart';

class NonEmployeeHomeScreen extends StatefulWidget {
  const NonEmployeeHomeScreen({super.key});

  @override
  State<NonEmployeeHomeScreen> createState() => _NonEmployeeHomeScreenState();
}

class _NonEmployeeHomeScreenState extends State<NonEmployeeHomeScreen> {
  final JobsController _c = Get.put(JobsController());
  // 🔹 Add this list inside your State class
  final List<Map<String, String>> quotes = [
    {
      "en": "🚀 Your future career starts here",
      "ar": "مستقبلك الوظيفي يبدأ من هنا",
    },
    {
      "en": "💡 Every interview is a new opportunity",
      "ar": "كل مقابلة هي فرصة جديدة",
    },
    {
      "en": "🌟 Keep moving forward, success awaits",
      "ar": "استمر في التقدم، النجاح بانتظارك",
    },
    {
      "en": "📈 Small steps lead to big achievements",
      "ar": "الخطوات الصغيرة تقود لإنجازات كبيرة",
    },
    {"en": "🤝 Build your future with confidence", "ar": "ابنِ مستقبلك بثقة"},
  ];

  late Map<String, String> randomQuote;

  @override
  void initState() {
    super.initState();
    _c.fetchJobs();
    _c.fetchUpcomingInterview();

    // 🔹 Pick random quote once
    randomQuote = (quotes..shuffle()).first;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.75; // الكروت أصغر شوي
    final interviewCardWidth = screenWidth * 0.7;

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
                    height: 220, // أصغر شوي من قبل
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder:
                          (_, i) => SizedBox(
                            width: cardWidth,
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

                const SizedBox(height: 25),

                // 🔹 Upcoming Interviews Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.calendar_month, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        "Upcoming Interviews",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Obx(() {
                  if (_c.upcomingInterviews.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No upcoming interviews.",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _c.upcomingInterviews.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final interview = _c.upcomingInterviews[i];
                        return Container(
                          width: interviewCardWidth,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${interview.jobTitle} Interview",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.event,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      interview.scheduledAt,
                                      style: const TextStyle(fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.videocam_outlined,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        try {
                                          final uri = Uri.parse(
                                            interview.meetingLink,
                                          );
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(
                                              uri,
                                              mode:
                                                  LaunchMode
                                                      .externalApplication,
                                            );
                                          } else {
                                            _showDialog(
                                              context,
                                              "Meeting Link",
                                              "⚠️ The link may not work right now.\nIt will be activated on the meeting day.",
                                            );
                                          }
                                        } catch (_) {
                                          _showDialog(
                                            context,
                                            "Error",
                                            "⚠️ Invalid meeting link.",
                                          );
                                        }
                                      },
                                      child: Text(
                                        interview.meetingLink,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "By: ${interview.interviewerName}",
                                      style: const TextStyle(fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 20),

                Center(
                  child: Column(
                    children: [
                      Text(
                        randomQuote["en"]!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        randomQuote["ar"]!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const SizedBox(height: 30),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(message, style: const TextStyle(fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }
}

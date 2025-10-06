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
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _c.fetchJobs();
    _c.fetchUpcomingInterview();
    randomQuote = (quotes..shuffle()).first;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.8;
    final interviewCardWidth = screenWidth * 0.75;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Obx(() {
          return RefreshIndicator(
            onRefresh: () async {
              await _c.fetchJobs();
              await _c.fetchUpcomingInterview();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 20,
                    ),
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
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Ready to find your next Job?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 🔹 Jobs Section
                  _sectionHeader(
                    "Recommended Jobs",
                    Icons.work_outline,
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllJobsPage(jobs: _c.jobs),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  if (_c.isLoading.value)
                    const Center(child: CircularProgressIndicator())
                  else if (_c.jobs.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No jobs available right now.",
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 260,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (_, i) {
                          final job = _c.jobs[i];
                          if (searchQuery.isNotEmpty &&
                              !job.jobTitle.toLowerCase().contains(
                                searchQuery,
                              ) &&
                              !job.location.toLowerCase().contains(
                                searchQuery,
                              )) {
                            return const SizedBox(); // يخفي اللي ما يطابق البحث
                          }
                          return SizedBox(
                            width: cardWidth,
                            child: JobCard(
                              job: job,
                              onApply: () => _c.applyToJob(job.jobId),
                              isApplied: _c.appliedJobIds.contains(job.jobId),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemCount: _c.jobs.length,
                      ),
                    ),

                  const SizedBox(height: 32),

                  // 🔹 Interviews Section
                  _sectionHeader("Upcoming Interviews", Icons.calendar_month),
                  const SizedBox(height: 14),

                  Obx(() {
                    if (_c.upcomingInterviews.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "No upcoming interviews.",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 190,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _c.upcomingInterviews.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (_, i) {
                          final interview = _c.upcomingInterviews[i];
                          return Container(
                            width: interviewCardWidth,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${interview.jobTitle} Interview",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                _rowIconText(
                                  Icons.event,
                                  interview.scheduledAt,
                                ),
                                _rowLink(interview.meetingLink),
                                _rowIconText(
                                  Icons.person,
                                  "By: ${interview.interviewerName}",
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 40),

                  // 🔹 Quote
                  Center(
                    child: Column(
                      children: [
                        Text(
                          randomQuote["en"]!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          randomQuote["ar"]!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }

  Widget _sectionHeader(String title, IconData icon, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                "See All →",
                style: TextStyle(color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _rowIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _rowLink(String link) {
    return Row(
      children: [
        const Icon(Icons.videocam_outlined, size: 16, color: Colors.blue),
        const SizedBox(width: 6),
        Expanded(
          child: InkWell(
            onTap: () async {
              try {
                final uri = Uri.parse(link);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              } catch (_) {
                _showDialog(context, "Error", "⚠️ Invalid meeting link.");
              }
            },
            child: Text(
              link,
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

class AllJobsPage extends StatelessWidget {
  final List jobs;
  const AllJobsPage({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Jobs"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: jobs.length,
        itemBuilder:
            (_, i) => JobCard(
              job: jobs[i],
              onApply: () {}, // ممكن تربطها بالكنترولر كمان
              isApplied: false,
            ),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
      ),
    );
  }
}

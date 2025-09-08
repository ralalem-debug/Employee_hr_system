import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/controllers/jobs_controller.dart';
import 'package:hr_system_/models/jobs/job_mode.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onApply;
  final bool isApplied;

  const JobCard({
    super.key,
    required this.job,
    required this.onApply,
    required this.isApplied,
  });

  @override
  Widget build(BuildContext context) {
    final JobsController _c = Get.find(); // ✅ استخدام JobsController

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffcfe6ff),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان + تفاصيل
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.work_outline, size: 28, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.jobTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      job.jobLevel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  final jobDetails = await _c.fetchJobDetails(job.jobId);
                  if (jobDetails != null) {
                    _showJobDetails(context, jobDetails, onApply, isApplied);
                  }
                },
                child: const Text("Show Details"),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            job.jobDescriptionSummary.isEmpty
                ? "No summary provided."
                : job.jobDescriptionSummary,
            style: const TextStyle(fontSize: 13, height: 1.35),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.place_outlined, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(job.location)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text("Employment Type: ${job.employmentType}")),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: isApplied ? null : onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isApplied ? Colors.grey : Colors.blue[700],
                  ),
                  child: Text(isApplied ? "Applied" : "Apply"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📌 BottomSheet
  void _showJobDetails(
    BuildContext ctx,
    JobModel job,
    VoidCallback onApply,
    bool isApplied,
  ) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.5,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder:
              (_, controller) => SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Text(
                      job.jobTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${job.department} • ${job.jobLevel}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const Divider(height: 24),

                    _sec("Summary", job.jobDescriptionSummary),
                    _sec("Required Qualifications", job.requiredQualifications),
                    _sec("Responsibilities", job.responsibilities),
                    _sec("Required Experience", job.requiredExperience),
                    _sec("Skills & Competencies", job.skillsAndCompetencies),
                    _sec("Work Shift Hours", job.workShiftHours),

                    const SizedBox(height: 16),
                    Text(
                      "Deadline: ${job.applicationDeadline.toLocal()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isApplied ? null : onApply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isApplied ? Colors.grey : Colors.blue[800],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          isApplied ? "Already Applied" : "Apply Now",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }

  Widget _sec(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(body.isEmpty ? "-" : body),
        ],
      ),
    );
  }
}

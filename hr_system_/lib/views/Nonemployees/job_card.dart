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
    final JobsController _c = Get.find();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.work_outline, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.jobTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        job.jobLevel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  final jobDetails = await _c.fetchJobDetails(job.jobId);
                  if (jobDetails != null) {
                    _c.setSelectedJob(job.jobId);
                    _showJobDetails(context, jobDetails, onApply, isApplied);
                  }
                },
                child: const Text("Details →"),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            job.jobDescriptionSummary.isEmpty
                ? "No summary provided."
                : job.jobDescriptionSummary,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.black87,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 14),

          // 🔹 زر Apply / Applied فقط
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: isApplied ? null : onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApplied ? Colors.grey : Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child:
                    isApplied
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Applied",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                        : const Text(
                          "Apply Now",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 BottomSheet تفاصيل الوظيفة
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

import 'package:flutter/material.dart';
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
                onPressed: () => _showJobDetails(context, job),
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
              OutlinedButton(
                onPressed: () => _shareJob(context, job),
                child: const Text("Share"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: isApplied ? null : onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isApplied ? Colors.grey : Colors.blue,
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

  void _shareJob(BuildContext ctx, JobModel job) {
    final txt =
        "Job: ${job.jobTitle}\nLevel: ${job.jobLevel}\nLocation: ${job.location}\nType: ${job.employmentType}";
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(SnackBar(content: Text("Copied details to share:\n$txt")));
  }

  void _showJobDetails(BuildContext ctx, JobModel job) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SingleChildScrollSheet(job: job);
      },
    );
  }
}

/// لو بدك تعمل تفاصيل موسعة، اعمل Widget جديد (مثلاً SingleChildScrollSheet)
class SingleChildScrollSheet extends StatelessWidget {
  final JobModel job;
  const SingleChildScrollSheet({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.jobTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            "${job.department} • ${job.jobLevel}",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Text(job.jobDescriptionSummary),
        ],
      ),
    );
  }
}

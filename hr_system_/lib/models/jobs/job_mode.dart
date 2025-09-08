// lib/model/jobs/job_model.dart
class JobModel {
  final String jobId;
  final String jobTitle;
  final String department;
  final String location;
  final String employmentType; // "Full Time", "Part Time"...
  final String jobLevel; // "Mid-Senior"...
  final String workShiftHours; // e.g. "08:30:00-17:00:00"
  final String jobDescriptionSummary;
  final String requiredQualifications;
  final String responsibilities;
  final String requiredExperience;
  final String skillsAndCompetencies;
  final DateTime postedAt;
  final DateTime applicationDeadline;

  JobModel({
    required this.jobId,
    required this.jobTitle,
    required this.department,
    required this.location,
    required this.employmentType,
    required this.jobLevel,
    required this.workShiftHours,
    required this.jobDescriptionSummary,
    required this.requiredQualifications,
    required this.responsibilities,
    required this.requiredExperience,
    required this.skillsAndCompetencies,
    required this.postedAt,
    required this.applicationDeadline,
  });

  factory JobModel.fromJson(Map<String, dynamic> j) {
    return JobModel(
      jobId: (j['jobId'] ?? "").toString(),
      jobTitle: (j['jobTitle'] ?? "").toString(),
      department: (j['department'] ?? "").toString(),
      location: (j['location'] ?? "").toString(),
      employmentType: (j['employmentType'] ?? "").toString(),
      jobLevel: (j['jobLevel'] ?? "").toString(),
      workShiftHours: (j['workShiftHours'] ?? "").toString(),
      jobDescriptionSummary: (j['jobDescriptionSummary'] ?? "").toString(),
      requiredQualifications: (j['requiredQualifications'] ?? "").toString(),
      responsibilities: (j['responsibilities'] ?? "").toString(),
      requiredExperience: (j['requiredExperience'] ?? "").toString(),
      skillsAndCompetencies: (j['skillsAndCompetencies'] ?? "").toString(),
      postedAt:
          DateTime.tryParse((j['postedAt'] ?? "").toString()) ?? DateTime.now(),
      applicationDeadline:
          DateTime.tryParse((j['applicationDeadline'] ?? "").toString()) ??
          DateTime.now(),
    );
  }
}

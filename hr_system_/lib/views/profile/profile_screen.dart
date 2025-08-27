import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_system_/views/profile/editpersonalinfoscreen.dart';
import 'package:hr_system_/views/profile/editprofessionalinfoscreen.dart';
import 'package:hr_system_/views/profile/upload_doc_screen.dart';
import '../../controllers/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController controller = Get.put(ProfileController());

  final String baseUrl = "http://192.168.1.128:5000";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: Colors.blue.shade50,
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xff2563eb),
                size: 25,
              ),
              onPressed: () => Get.offAllNamed('/home'),
              tooltip: 'Back to Home',
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value != null) {
          return Center(
            child: Text(
              controller.error.value!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        final personal = controller.personalInfo.value;
        final professional = controller.professionalInfo.value;
        final docs = controller.documents.value;

        if (personal == null || professional == null) {
          return const Center(child: Text("Profile data not found."));
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 0),
          children: [
            // Profile picture + name card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Card(
                elevation: 8,
                shadowColor: Colors.blue.withOpacity(0.13),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(34),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 26,
                    horizontal: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile picture with border effect
                      // Profile picture with border effect
                      // Profile picture with upload button
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // الصورة نفسها
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xff2563eb),
                                  Colors.blue.shade200,
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.blue.shade50,
                              backgroundImage:
                                  (personal.imageUrl != null &&
                                          personal.imageUrl!.isNotEmpty)
                                      ? NetworkImage(
                                        personal.imageUrl!,
                                      ) // ✅ صار كامل من الكنترولر
                                      : null,
                              child:
                                  (personal.imageUrl == null ||
                                          personal.imageUrl!.isEmpty)
                                      ? Text(
                                        personal.fullNameEng.isNotEmpty
                                            ? personal.fullNameEng
                                                .substring(0, 2)
                                                .toUpperCase()
                                            : "", // ✅ fallback إذا الاسم فاضي
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      )
                                      : null,
                            ),
                          ),

                          // زر الكاميرا/الرفع
                          Positioned(
                            bottom: 0,
                            right: 6,
                            child: GestureDetector(
                              onTap: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxHeight: 800,
                                  maxWidth: 800,
                                  imageQuality: 85,
                                );

                                if (picked != null) {
                                  final file = File(picked.path);
                                  final ok = await controller
                                      .uploadProfileImage(file);
                                  if (ok) {
                                    // ✅ بعد الرفع مباشرة أعمل fetchProfile
                                    await controller.fetchProfile();

                                    Get.snackbar(
                                      "Success",
                                      "Profile image updated",
                                    );
                                  }
                                }
                              },

                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Color(0xff2563eb),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
                      Text(
                        personal.fullNameEng,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xff1e293b),
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (personal.fullNameArb.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.5),
                          child: Text(
                            personal.fullNameArb,
                            style: TextStyle(
                              color: Colors.blueGrey[600],
                              fontSize: 15.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.07,
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _chip(personal.personalEmail, Icons.email_rounded),
                          if (personal.phoneNumber.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: _chip(personal.phoneNumber, Icons.phone),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            // --- Personal Information ---
            _sectionTitle(
              context,
              "Personal Information",
              Icons.person_rounded,
              onEdit:
                  () => Get.to(
                    () => EditPersonalInfoScreen(controller: controller),
                  ),
            ),
            _profileCard([
              _infoRow("Birthday", personal.birthday, Icons.cake_outlined),
              _infoRow("Gender", personal.gender, Icons.wc_outlined),
              _infoRow(
                "Marital Status",
                personal.maritalStatus,
                Icons.favorite_border,
              ),
              _infoRow(
                "Nationality",
                personal.nationality,
                Icons.flag_outlined,
              ),

              if ((personal.nationalId.isNotEmpty == true) &&
                  (personal.iDno.isNotEmpty == true)) ...[
                _infoRow(
                  "National ID",
                  personal.nationalId,
                  Icons.badge_outlined,
                ),
                _infoRow(
                  "ID No.",
                  personal.iDno,
                  Icons.confirmation_number_outlined,
                ),
              ] else ...[
                _infoRow(
                  "Passport No.",
                  personal.passportNumber ?? "-",
                  Icons.airplanemode_active_outlined,
                ),
              ],

              _infoRow(
                "Residency",
                personal.residency,
                Icons.home_work_outlined,
              ),
              _infoRow(
                "Birth Place",
                personal.birthPlace,
                Icons.location_city_outlined,
              ),
              _infoRow("Address", personal.address, Icons.location_on_outlined),
            ]),

            // --- Professional Information ---
            _sectionTitle(
              context,
              "Professional Information",
              Icons.work_outline_rounded,
              onEdit:
                  () => Get.to(
                    () => EditProfessionalInfoScreen(controller: controller),
                  ),
            ),
            _profileCard([
              _infoRow(
                "Department",
                professional.departmentName,
                Icons.apartment_rounded,
              ),
              _infoRow(
                "Job Title",
                professional.jobTitleName,
                Icons.verified_user_outlined,
              ),
              _infoRow(
                "Employment Type",
                professional.employmentType,
                Icons.schedule,
              ),
              _infoRow("Work Email", professional.email, Icons.email_rounded),
              _infoRow(
                "Salary",
                professional.salary.toString(),
                Icons.attach_money_rounded,
              ),
              _infoRow(
                "IBAN",
                professional.iban,
                Icons.account_balance_rounded,
              ),
              _infoRow(
                "Hire Date",
                professional.hireDate,
                Icons.event_available_outlined,
              ),
              _infoRow(
                "Termination Date",
                professional.terminationDate,
                Icons.event_busy_outlined,
              ),
              _infoRow(
                "Annual Leave",
                professional.annualLeaveBalance.toString(),
                Icons.beach_access_outlined,
              ),
              _infoRow(
                "Sick Leave",
                professional.sickLeaveBalance.toString(),
                Icons.healing_outlined,
              ),
            ]),

            // --- Documents Section ---
            _sectionTitle(
              context,
              "Documents",
              Icons.folder_open_rounded,
              onEdit:
                  () =>
                      Get.to(() => EditDocumentsScreen(controller: controller)),
            ),
            _profileCard([
              _docRow("CV", docs?.cv, Icons.description_rounded),
              _docRow(
                "University Certificate",
                docs?.universityCertificate,
                Icons.school,
              ),
              _docRow("Contract", docs?.contract, Icons.assignment_turned_in),
              _docRow(
                "National Identity",
                docs?.nationalIdentity,
                Icons.perm_identity,
              ),
              _docRow("Passport", docs?.passport, Icons.card_travel_rounded),
              _docRow("Signature", docs?.signature, Icons.border_color),
              _docRow("Other", docs?.other, Icons.attach_file),

              if (docs != null && docs.certificates.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 2, top: 2, bottom: 5),
                  child: Text(
                    "Other Certificates:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                ...docs.certificates.map(
                  (url) => _docRow("Certificate", url, Icons.insert_drive_file),
                ),
              ],
            ]),
          ],
        );
      }),
    );
  }

  // Card container
  Widget _profileCard(List<Widget> children) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    child: Card(
      color: Colors.white,
      elevation: 2.5,
      shadowColor: Colors.blueGrey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...children],
        ),
      ),
    ),
  );

  Widget _infoRow(String label, String? value, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue.shade400, size: 19),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 117,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.blueGrey[800],
              fontWeight: FontWeight.w600,
              fontSize: 14.2,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value ?? "-",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.2,
              color: Color(0xff475569),
            ),
          ),
        ),
      ],
    ),
  );

  // ✅ Document row مع زر تحميل واسم الملف
  Widget _docRow(String label, String? url, IconData icon) {
    final fileName =
        (url == null || url.isEmpty)
            ? "No file"
            : url.split('/').last; // اسم الملف من الرابط

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // أيقونة على اليسار
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.lightBlue.shade400, size: 18),
          ),
          const SizedBox(width: 14),

          // اسم المستند
          Expanded(
            child: Text(
              "$label: $fileName",
              style: TextStyle(
                color: Colors.blueGrey[800],
                fontSize: 14.2,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // زر التحميل/الفتح
          if (url != null && url.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.download_rounded,
                color: Color(0xff2563eb),
                size: 20,
              ),
              tooltip: "Open / Download",
              onPressed: () {
                controller.downloadDocument(
                  label,
                  url.split('.').last,
                  directUrl: url,
                ); // استدعاء دالة التحميل
              },
            ),
        ],
      ),
    );
  }

  Widget _chip(String value, IconData icon) => Container(
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 16),
        const SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 13.4,
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onEdit,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 16, top: 17, right: 18),
    child: Row(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 21),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xff2563eb),
            fontSize: 16.7,
            letterSpacing: 0.1,
          ),
        ),
        const Spacer(),
        if (onEdit != null)
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: Icon(Icons.edit, color: Colors.blue.shade700, size: 21),
              tooltip: "Edit",
              onPressed: onEdit,
            ),
          ),
      ],
    ),
  );
}

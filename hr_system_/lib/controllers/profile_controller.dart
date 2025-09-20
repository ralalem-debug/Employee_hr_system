import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:hr_system_/app_config.dart';
import 'package:hr_system_/models/profile%20page/Documents_info_model.dart';
import 'package:hr_system_/models/profile%20page/personal_info_model.dart';
import 'package:hr_system_/models/profile%20page/professional_info_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart' as dio;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ProfileController extends GetxController {
  var personalInfo = Rxn<PersonalInfoModel>();
  var professionalInfo = Rxn<ProfessionalInfoModel>();
  var documents = Rxn<DocumentsModel>();

  var isLoading = false.obs;
  var error = RxnString();

  final String baseUrl = AppConfig.baseUrl;

  final storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getAuthData() async {
    final token = await storage.read(key: 'auth_token') ?? '';
    final employeeId = await storage.read(key: 'employee_id') ?? '';
    return {"token": token, "employeeId": employeeId};
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    error.value = null;

    try {
      final auth = await _getAuthData();
      final token = auth["token"]!;
      final employeeId = auth["employeeId"] ?? "";
      print("🔑 Token: $token");
      print("🆔 EmployeeId (not used in API calls): $employeeId");

      final personalResponse = await http.get(
        Uri.parse('$baseUrl/employee/get-personal-info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("📥 Personal Info URL: $baseUrl/employee/get-personal-info");
      print(
        "📥 Response: ${personalResponse.statusCode} => ${personalResponse.body}",
      );

      if (personalResponse.statusCode == 200) {
        personalInfo.value = PersonalInfoModel.fromJson(
          jsonDecode(personalResponse.body),
        );
      } else {
        throw Exception(
          "Error loading personal info: ${personalResponse.body}",
        );
      }

      // --- Professional Info ---
      final professionalResponse = await http.get(
        Uri.parse('$baseUrl/employee/get-professional-info'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print(
        "📥 Professional Info Response: ${professionalResponse.statusCode} => ${professionalResponse.body}",
      );

      if (professionalResponse.statusCode == 200) {
        final data = jsonDecode(professionalResponse.body);
        professionalInfo.value = ProfessionalInfoModel(
          departmentName: data['departmentName'] ?? '',
          jobTitleName: data['jobTitleName'] ?? '',
          employmentType: data['employmentType'] ?? '',
          email: data['email'] ?? '',
          salary:
              (data['salary'] is num)
                  ? (data['salary'] as num).toDouble()
                  : double.tryParse("${data['salary']}") ?? 0,
          iban: data['iban'] ?? '',
          hireDate: data['hireDate'] ?? '',
          terminationDate: data['terminationDate'],
          annualLeaveBalance: data['annualLeaveBalance'] ?? 0,
          sickLeaveBalance: data['sickLeaveBalance'] ?? 0,
          departmentId: data['departmentId'],
          jobTitleId: data['jobTitleId'],
        );
      } else {
        throw Exception(
          "Error loading professional info: ${professionalResponse.body}",
        );
      }

      // --- Documents ---
      final docsResponse = await http.get(
        Uri.parse('$baseUrl/employee/get-employee-documents'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print(
        "📥 Documents Response: ${docsResponse.statusCode} => ${docsResponse.body}",
      );

      if (docsResponse.statusCode == 200) {
        documents.value = DocumentsModel.fromJson(
          jsonDecode(docsResponse.body),
        );
      } else {
        throw Exception("Error loading documents: ${docsResponse.body}");
      }

      // --- User Image ---
      await fetchUserImage();
    } catch (e) {
      error.value = e.toString();
      print("❌ fetchProfile error: $e");
    }

    isLoading.value = false;
  }

  Future<bool> updatePersonalInfo(PersonalInfoModel model) async {
    isLoading.value = true;
    error.value = null;

    try {
      final auth = await _getAuthData();
      final token = auth["token"]!;
      final employeeId = auth["employeeId"]!;

      final data = {
        "employeeId": employeeId,
        "fullNameArb": model.fullNameArb,
        "fullNameEng": model.fullNameEng,
        "personalEmail": model.personalEmail,
        "phoneNumber": model.phoneNumber,
        "birthday": model.birthday,
        "maritalStatus": model.maritalStatus,
        "gender": model.gender,
        "nationality": model.nationality,
        "nationalId": model.nationalId,
        "iDno": model.iDno,
        "serialno": model.serialNo,
        "residency": model.residency,
        "birthPlace": model.birthPlace,
        "address": model.address,
      };

      if (model.passportNumber != null && model.passportNumber!.isNotEmpty) {
        data["passportNumber"] = model.passportNumber;
      }

      final res = await http.put(
        Uri.parse('$baseUrl/employee/update-personal-info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (res.statusCode == 200) {
        // ✅ عدل البيانات محلياً بدل ما تعيد تحميل كامل
        personalInfo.value = model;
        personalInfo.refresh();
        return true;
      } else {
        print("❌ Personal update failed: ${res.statusCode} => ${res.body}");
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      print("❌ Exception in updatePersonalInfo: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ جلب الأقسام
  Future<List<Map<String, dynamic>>> fetchDepartments() async {
    final auth = await _getAuthData();
    final token = auth["token"]!;

    final res = await http.get(
      Uri.parse('$baseUrl/company/departments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("📥 Departments Response: ${res.body}");

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print("❌ Failed to load departments: ${res.body}");
      return [];
    }
  }

  // ✅ جلب المسميات الوظيفية
  Future<List<Map<String, dynamic>>> fetchJobTitles() async {
    final auth = await _getAuthData();
    final token = auth["token"]!;

    final res = await http.get(
      Uri.parse('$baseUrl/company/JobTitles'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("📥 JobTitles Response: ${res.body}");

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print("❌ Failed to load job titles: ${res.body}");
      return [];
    }
  }

  // ✅ تحديث المعلومات المهنية
  Future<bool> updateProfessionalInfo(
    String departmentId,
    String jobTitleId,
    String employmentType,
    String email,
    double salary,
    String iban,
    String hireDate,
    String? terminationDate,
    int annualLeave,
    int sickLeave,
  ) async {
    try {
      final auth = await _getAuthData();
      final token = auth["token"]!;
      final employeeId = auth["employeeId"]!;

      final res = await http.put(
        Uri.parse('$baseUrl/employee/update-professional-info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "employeeId": employeeId,
          "departmentId": departmentId,
          "jobTitleId": jobTitleId,
          "employmentType": employmentType,
          "email": email,
          "salary": salary,
          "iban": iban,
          "hireDate": hireDate,
          "terminationDate": terminationDate,
          "annualLeaveBalance": annualLeave,
          "sickLeaveBalance": sickLeave,
        }),
      );

      if (res.statusCode == 200) {
        await fetchProfile();
        return true;
      } else {
        print("❌ Professional update failed: ${res.statusCode} => ${res.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception in updateProfessionalInfo: $e");
      return false;
    }
  }

  Future<String?> uploadProfileImage(File file) async {
    try {
      final auth = await _getAuthData();
      final token = auth["token"]!;

      final formData = dio.FormData.fromMap({
        "file": await dio.MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await dio.Dio().post(
        "$baseUrl/Auth/upload-user-image",
        data: formData,
        options: dio.Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200) {
        await fetchUserImage();
        return "Image uploaded successfully!";
      } else {
        return "Upload failed [${response.statusCode}]";
      }
    } catch (e) {
      return "❌ Exception: $e";
    }
  }

  Future<void> fetchUserImage() async {
    try {
      final auth = await _getAuthData();
      final token = auth["token"]!;
      final userId = await storage.read(key: 'user_id') ?? '';

      if (userId.isEmpty) {
        print("❌ No userId found in storage");
        return;
      }

      final response = await dio.Dio().get(
        "$baseUrl/Auth/user-image",
        queryParameters: {"userId": userId},
        options: dio.Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      print(
        "📷 User Image Response: ${response.statusCode} => ${response.data}",
      );

      if (response.statusCode == 200) {
        String? imageUrl;

        // التحقق من نوع الرد
        if (response.data is String) {
          imageUrl = response.data as String;
        } else if (response.data is Map<String, dynamic>) {
          imageUrl = response.data["url"] ?? response.data["imageUrl"];
        }

        // إذا كانت الصورة موجودة
        if (imageUrl != null && imageUrl.isNotEmpty) {
          if (personalInfo.value != null) {
            // تعديل الـ base URL حسب الحاجة (إزالة "/api" إذا كانت موجودة)
            String finalImageUrl =
                imageUrl.startsWith("http")
                    ? imageUrl
                    : "$baseUrl$imageUrl".replaceFirst('/api', '');

            personalInfo.value = personalInfo.value!.copyWith(
              imageUrl: finalImageUrl,
            );
            personalInfo.refresh();
          }
        }
      } else if (response.statusCode == 404) {
        print("ℹ️ No user image found (404)");
      } else {
        print(
          "❌ Unexpected response: ${response.statusCode} => ${response.data}",
        );
      }
    } catch (e) {
      print("❌ fetchUserImage error: $e");
    }
  }

  Future<bool> uploadDocument(String fieldName, File file) async {
    try {
      final auth = await _getAuthData();
      final token = auth["token"]!;
      final employeeId = auth["employeeId"]!;

      final formData = dio.FormData.fromMap({
        "EmployeeId": employeeId,
        fieldName: await dio.MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await dio.Dio().post(
        "$baseUrl/employee/upload-employee-documents",
        data: formData,
        options: dio.Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200) {
        await fetchProfile();
        return true;
      } else {
        print("❌ Upload failed [${response.statusCode}]: ${response.data}");
        return false;
      }
    } catch (e) {
      Get.snackbar("❌ Exception", e.toString());
      print("❌ Exception in uploadDocument: $e");
      return false;
    }
  }

  Future<bool> downloadDocument(
    String type,
    String extension, {
    String? directUrl,
  }) async {
    try {
      final auth = await _getAuthData();
      final token = auth["token"]!;

      if (directUrl == null || directUrl.isEmpty) {
        throw Exception("No direct URL provided for $type");
      }

      // لو السيرفر مرجع الرابط بدون http أضف baseUrl
      final url =
          directUrl.startsWith("http") ? directUrl : "$baseUrl$directUrl";

      Directory dir;

      if (Platform.isAndroid) {
        // 📂 Android → Download folder
        dir = Directory("/storage/emulated/0/Download");
        if (!dir.existsSync()) {
          dir =
              await getExternalStorageDirectory() ??
              await getTemporaryDirectory();
        }
      } else if (Platform.isIOS) {
        // 🍏 iOS → Documents folder (يظهر في Files app)
        dir = await getApplicationDocumentsDirectory();
      } else {
        dir = await getTemporaryDirectory(); // fallback لأي نظام تاني
      }

      final savePath =
          "${dir.path}/$type-${DateTime.now().millisecondsSinceEpoch}.$extension";

      final response = await dio.Dio().download(
        url,
        savePath,
        options: dio.Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        await OpenFilex.open(savePath); // ✅ فتح الملف بعد التحميل
        Get.snackbar("✅ Success", "File downloaded to ${dir.path}");
        return true;
      } else {
        print("❌ Download failed [${response.statusCode}]: ${response.data}");
        Get.snackbar("❌ Error", "Download failed [${response.statusCode}]");
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar("❌ Error", e.toString());
      print("❌ Exception in downloadDocument: $e");
      return false;
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:hr_system_/models/profile%20page/Documents_info_model.dart';
import 'package:hr_system_/models/profile%20page/personal_info_model.dart';
import 'package:hr_system_/models/profile%20page/professional_info_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import 'package:open_filex/open_filex.dart';

class ProfileController extends GetxController {
  // البيانات
  var personalInfo = Rxn<PersonalInfoModel>();
  var professionalInfo = Rxn<ProfessionalInfoModel>();
  var documents = Rxn<DocumentsModel>();

  // حالة التحميل والخطأ
  var isLoading = false.obs;
  var error = RxnString();

  final String baseUrl = "http://192.168.1.213";

  // 🟢 Helper لجلب التوكن والـ employeeId من التخزين
  Future<Map<String, String>> _getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final employeeId = prefs.getString('employee_id') ?? '';
    return {"token": token, "employeeId": employeeId};
  }

  // ✅ جلب البيانات كلها
  Future<void> fetchProfile() async {
    isLoading.value = true;
    error.value = null;

    try {
      final auth = await _getAuthData();
      final token = auth["token"]!;
      final employeeId = auth["employeeId"]!;

      // --- Personal Info ---
      final personalResponse = await http.get(
        Uri.parse(
          '$baseUrl/api/employee/get-personal-info?employeeId=$employeeId',
        ),
        headers: {'Authorization': 'Bearer $token'},
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
        Uri.parse(
          '$baseUrl/api/employee/get-professional-info?employeeId=$employeeId',
        ),
        headers: {'Authorization': 'Bearer $token'},
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
        Uri.parse(
          '$baseUrl/api/employee/get-employee-documents?employeeId=$employeeId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (docsResponse.statusCode == 200) {
        documents.value = DocumentsModel.fromJson(
          jsonDecode(docsResponse.body),
        );
      } else {
        throw Exception("Error loading documents: ${docsResponse.body}");
      }
    } catch (e) {
      error.value = e.toString();
      print("❌ fetchProfile error: $e");
    }

    isLoading.value = false;
  }

  // ✅ تحديث المعلومات الشخصية
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
        Uri.parse('$baseUrl/api/employee/update-personal-info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (res.statusCode == 200) {
        await fetchProfile();
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
      Uri.parse('$baseUrl/api/company/departments'),
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
      Uri.parse('$baseUrl/api/company/JobTitles'),
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
        Uri.parse('$baseUrl/api/employee/update-professional-info'),
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
        "$baseUrl/api/employee/upload-employee-documents",
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

      // استخدم الرابط المباشر من السيرفر إذا موجود
      if (directUrl == null || directUrl.isEmpty) {
        throw Exception("No direct URL provided for $type");
      }

      // إذا السيرفر مرجع الرابط بدون http:// أضف baseUrl
      final url =
          directUrl.startsWith("http") ? directUrl : "$baseUrl$directUrl";

      // حفظ بالـ Downloads
      final dir = Directory("/storage/emulated/0/Download");
      if (!dir.existsSync()) dir.createSync(recursive: true);

      final savePath =
          "${dir.path}/$type-${DateTime.now().millisecondsSinceEpoch}.$extension";

      final response = await dio.Dio().download(
        url,
        savePath,
        options: dio.Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        await OpenFilex.open(savePath);
        return true;
      } else {
        print("❌ Download failed [${response.statusCode}]: ${response.data}");
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

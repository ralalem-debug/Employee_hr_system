import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AppConfig {
  /// 🔹 عنوان السيرفر (الـ API الأساسي)
  static String baseUrl = "http://46.185.162.66:30211/api";

  /// 🔹 حالة الاتصال بالسيرفر
  static bool serverReachable = false;

  /// 🔹 تهيئة التطبيق + فحص السيرفر
  static Future<void> init() async {
    try {
      debugPrint("🌐 Initializing AppConfig...");
      final success = await _checkServerConnection();
      serverReachable = success;

      if (success) {
        debugPrint("✅ Connected to server successfully → $baseUrl");
      } else {
        debugPrint("⚠️ Server not reachable → $baseUrl");
      }
    } catch (e) {
      debugPrint("❌ AppConfig init failed: $e");
      serverReachable = false;
    }
  }

  static Future<bool> _checkServerConnection() async {
    try {
      final uri = Uri.parse("$baseUrl/Auth/login");
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200 ||
          response.statusCode == 401; // 401 مقبولة لأنها تطلب تسجيل دخول
    } catch (_) {
      return false;
    }
  }
}

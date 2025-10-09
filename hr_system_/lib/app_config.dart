import 'dart:io';
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

  /// 🧩 دالة داخلية لفحص الاتصال بالسيرفر
  static Future<bool> _checkServerConnection() async {
    try {
      final uri = Uri.parse("$baseUrl/HealthCheck");
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      // إذا كان السيرفر عندك ما فيه endpoint HealthCheck، جرّب /Auth/login
      if (response.statusCode == 200) return true;
      return false;
    } on SocketException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
  }
}

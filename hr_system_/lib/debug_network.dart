import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:hr_system_/app_config.dart';

class DebugNetwork {
  static Future<void> testConnection() async {
    print("🔍 Testing backend connectivity...");
    print("🌐 Base URL in use: ${AppConfig.baseUrl}");

    // جرّب تستخرج الهوست من الـ BaseUrl
    final uri = Uri.parse(AppConfig.baseUrl);
    final host = uri.host;

    try {
      // نطبع كل IPs اللي resolve للهوست
      final ips = await InternetAddress.lookup(host);
      for (final ip in ips) {
        print("🌐 Candidate resolved IP: ${ip.address}");
      }
    } catch (e) {
      print("❌ Error resolving host: $e");
    }

    // نجهز رابط swagger (عادة على الجذر)
    final base = AppConfig.baseUrl.replaceFirst('/api', '');
    final url = "$base/swagger/index.html";
    print("🔗 Swagger URL: $url");

    try {
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      print("📥 Response: ${res.statusCode}");
      if (res.statusCode == 200) {
        final snippet =
            res.body.length > 200 ? res.body.substring(0, 200) : res.body;
        print("📦 Body snippet: $snippet");
      } else {
        print("⚠️ Non-200 response: ${res.body}");
      }
    } catch (e) {
      print("❌ Error reaching backend: $e");
    }
  }

  Future<void> fixBaseUrlOnce() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'base_url'); // امسح القديم (172.*)
    await storage.write(
      key: 'base_url',
      value: 'http://192.168.1.158:5000/api', // عدّل IP حسب جهازك
    );
  }
}

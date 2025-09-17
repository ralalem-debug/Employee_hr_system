import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_system_/udp_discovery.dart';

class AppConfig {
  static String baseUrl = const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.158/api',
  );

  static const _storage = FlutterSecureStorage();
  static const _key = 'base_url';

  static Future<void> init() async {
    final saved = await _storage.read(key: _key);
    if (saved != null && saved.isNotEmpty) {
      baseUrl = saved;
      return;
    }

    final discovered = await discoverBaseUrlViaUdp();
    if (discovered != null) {
      baseUrl = discovered;
      await _storage.write(key: _key, value: discovered);
    }
  }

  static Future<void> save(String url) async {
    baseUrl = url;
    await _storage.write(key: _key, value: url);
  }
}

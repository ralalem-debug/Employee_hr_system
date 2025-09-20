import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'hrms_discovery.dart';

class AppConfig {
  static String baseUrl = const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.184:5000/api',
  );

  static const _storage = FlutterSecureStorage();
  static const _key = 'base_url';

  static bool _isBadHost(String host) =>
      host.startsWith('172.') ||
      host.startsWith('127.') ||
      host.startsWith('169.254.');

  static Future<bool> _canReach(String url) async {
    try {
      final base = url.replaceFirst('/api', '');
      final res = await http
          .get(Uri.parse('$base/swagger/index.html'))
          .timeout(const Duration(seconds: 3));
      return res.statusCode >= 200 && res.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  static String _ensureApi(String url) =>
      url.endsWith('/api') ? url : '$url/api';

  static Future<void> init() async {
    final saved = await _storage.read(key: _key);
    if (saved != null && saved.isNotEmpty) {
      final host = Uri.parse(saved).host;
      if (!_isBadHost(host) && await _canReach(saved)) {
        baseUrl = saved;
        print('✅ Using saved baseUrl: $baseUrl');
        return;
      }
    }

    final discovery = HrmsDiscovery();
    final discovered = await discovery.discoverBackend(
      timeout: Duration(seconds: 6),
      retries: 3,
    );
    if (discovered != null &&
        !_isBadHost(Uri.parse(discovered).host) &&
        await _canReach(discovered)) {
      baseUrl = _ensureApi(discovered);
      await _storage.write(key: _key, value: baseUrl);
      print('✅ Using discovered baseUrl: $baseUrl');
      return;
    }

    for (final candidate in <String>[
      'http://192.168.1.184:5000/api',
      'http://10.0.2.2:5000/api',
    ]) {
      if (await _canReach(candidate)) {
        baseUrl = candidate;
        await _storage.write(key: _key, value: baseUrl);
        print('✅ Using fallback baseUrl: $baseUrl');
        return;
      }
    }

    print('⚠️ Falling back to default baseUrl: $baseUrl');
  }

  static Future<void> reset() async {
    await _storage.delete(key: _key);
    print('🧼 Cleared stored base_url');
  }
}

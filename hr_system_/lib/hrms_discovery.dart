import 'dart:async';
import 'package:multicast_dns/multicast_dns.dart';

class HrmsDiscovery {
  final String serviceType = '_hrms._tcp.local';

  Future<String?> discoverBackend({
    Duration timeout = const Duration(seconds: 5),
    int retries = 3,
  }) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      print("🔍 Discovery attempt $attempt/$retries ...");

      final MDnsClient client = MDnsClient();
      await client.start();

      try {
        await for (final PtrResourceRecord ptr in client
            .lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer(serviceType),
            )
            .timeout(timeout)) {
          await for (final SrvResourceRecord srv in client
              .lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(ptr.domainName),
              )
              .timeout(timeout)) {
            await for (final IPAddressResourceRecord addr in client
                .lookup<IPAddressResourceRecord>(
                  ResourceRecordQuery.addressIPv4(srv.target),
                )
                .timeout(timeout)) {
              final ip = addr.address.address;

              if (ip.startsWith('192.168.') || ip.startsWith('10.')) {
                final baseUrl = "http://$ip:${srv.port}/api";
                print("✅ Backend discovered at: $baseUrl");
                client.stop();
                return baseUrl;
              } else {
                print("❌ Ignoring non-LAN IP: $ip");
              }
            }
          }
        }
      } catch (e) {
        print("⚠️ Discovery failed on attempt $attempt: $e");
      } finally {
        client.stop();
      }

      await Future.delayed(const Duration(seconds: 2));
    }

    return null;
  }
}

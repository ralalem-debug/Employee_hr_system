import 'package:multicast_dns/multicast_dns.dart';

Future<void> debugDiscovery() async {
  final client = MDnsClient();
  await client.start();

  try {
    print("🔍 Browsing for ALL services on mDNS...");

    await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
      ResourceRecordQuery.serverPointer('_services._dns-sd._udp.local'),
    )) {
      print("📡 Service type: ${ptr.domainName}");
    }
  } catch (e) {
    print("❌ Error while discovering: $e");
  } finally {
    client.stop();
  }
}

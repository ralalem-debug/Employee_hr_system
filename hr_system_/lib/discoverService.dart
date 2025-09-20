import 'package:multicast_dns/multicast_dns.dart';

Future<String?> discoverService() async {
  final mdns = MDnsClient();
  await mdns.start();

  try {
    await for (final PtrResourceRecord ptr in mdns.lookup<PtrResourceRecord>(
      ResourceRecordQuery.serverPointer('_hrms._tcp.local'),
    )) {
      print('📡 Discovered service: ${ptr.domainName}');

      await for (final SrvResourceRecord srv in mdns.lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName),
      )) {
        print('➡ Host: ${srv.target}, Port: ${srv.port}');

        // نجيب IP للـ host
        await for (final IPAddressResourceRecord addr in mdns
            .lookup<IPAddressResourceRecord>(
              ResourceRecordQuery.addressIPv4(srv.target),
            )) {
          final ip = addr.address.address;

          if (ip.startsWith('192.168.') || ip.startsWith('10.')) {
            final url = "http://$ip:${srv.port}/api";
            print('✅ Backend found: $url');
            mdns.stop(); // نوقف أول ما نلاقي نتيجة صحيحة
            return url;
          } else {
            print('❌ Ignoring non-LAN IP: $ip');
          }
        }
      }

      await for (final TxtResourceRecord txt in mdns.lookup<TxtResourceRecord>(
        ResourceRecordQuery.text(ptr.domainName),
      )) {
        print('📝 TXT data: ${txt.text}');
      }
    }
  } catch (e) {
    print('❌ Discovery error: $e');
  } finally {
    mdns.stop();
  }

  return null; // ما لقى إشي
}

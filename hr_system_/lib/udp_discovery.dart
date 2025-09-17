import 'dart:convert';
import 'dart:async';
import 'package:udp/udp.dart';

Future<String?> discoverBaseUrlViaUdp({int port = 8888}) async {
  final sock = await UDP.bind(Endpoint.any(port: Port(port)));

  await sock.send(
    utf8.encode('WHO_IS_SERVER?'),
    Endpoint.broadcast(port: Port(port)),
  );

  try {
    final datagram = await sock.asStream().first.timeout(
      const Duration(seconds: 3),
    );
    if (datagram != null) {
      final msg = utf8.decode(datagram.data);

      // نتوقع JSON: {"baseUrl":"http://192.168.1.158/api"}
      final map = jsonDecode(msg);
      final url = map['baseUrl'] as String?;
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }
  } catch (_) {
  } finally {
    sock.close();
  }
  return null;
}

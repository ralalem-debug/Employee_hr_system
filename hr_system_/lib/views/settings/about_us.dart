import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  final String _url = "https://www.onsetway-it.com/about";

  Future<void> _openLink() async {
    final uri = Uri.parse(_url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $_url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 255, 255, 255)),

      body: Center(
        child: ElevatedButton.icon(
          onPressed: _openLink,
          icon: const Icon(Icons.open_in_browser),
          label: const Text("View About Us"),
        ),
      ),
    );
  }
}

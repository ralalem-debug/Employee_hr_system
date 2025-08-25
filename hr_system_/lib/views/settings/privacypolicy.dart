import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  final String _url = "https://www.onsetway-it.com/privacy-policy";

  Future<void> _openLink() async {
    final uri = Uri.parse(_url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw Exception("Could not launch $_url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _openLink,
          icon: const Icon(Icons.open_in_browser),
          label: const Text("View Privacy Policy"),
        ),
      ),
    );
  }
}

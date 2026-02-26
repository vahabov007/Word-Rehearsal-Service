import 'package:flutter/material.dart';
import '../config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              leading: const Icon(Icons.link),
              title: const Text("Backend base URL"),
              subtitle: Text(AppConfig.baseUrl),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            elevation: 0,
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("Tips"),
              subtitle: Text(
                "Android Emulator uses 10.0.2.2 to reach your PC localhost.\n"
                "Real phone needs your PC IP address (same Wi-Fi).",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
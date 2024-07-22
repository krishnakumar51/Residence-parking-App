// lib/views/settings_screen.dart

import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Add profile management options here
            SizedBox(height: 20),
            Text('Notification Settings'),
            // Add notification settings options here
            SizedBox(height: 20),
            Text('Voice Assistant Preferences'),
            // Add voice assistant preferences here
            SizedBox(height: 20),
            Text('Accessibility Options'),
            // Add accessibility options here
          ],
        ),
      ),
    );
  }
}

// lib/views/general_inquiries_screen.dart

import 'package:flutter/material.dart';

class GeneralInquiriesScreen extends StatelessWidget {
  const GeneralInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General Inquiries')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Frequently Asked Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Add FAQs here
            const SizedBox(height: 20),
            const Text('Submit a Query'),
            const TextField(
              decoration: InputDecoration(labelText: 'Your Query'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Submit query logic here
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

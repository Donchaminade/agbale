import 'package:flutter/material.dart';

class SocialMediasScreen extends StatelessWidget {
  const SocialMediasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Social Media Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'This screen is under construction.',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              'Please clarify how you intend to manage social media links at a top level.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
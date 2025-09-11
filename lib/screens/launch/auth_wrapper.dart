import 'package:abgbale/screens/auth/login.dart';
import 'package:abgbale/screens/dashboard/tableau.dart';
import 'package:abgbale/screens/launch/onboarding_screen.dart';
import 'package:abgbale/utils/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!hasSeenOnboarding) {
      return const OnboardingScreen();
    }

    final token = await TokenManager.getToken();
    if (token != null) {
      return const TableauScreen();
    } else {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        // Handle error case, though unlikely here
        return const Scaffold(
          body: Center(child: Text('An error occurred')),
        );
      },
    );
  }
}

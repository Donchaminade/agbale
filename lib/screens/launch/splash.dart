// import 'package:flutter/material.dart';
// import 'package:abgbale/screens/launch/onboarding.dart';
// import 'dart:async';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Timer(const Duration(seconds: 3), () {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const OnboardingScreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Placeholder for your logo
//             Image.asset(
//               'assets/logo.png', // Make sure you have an assets folder and a logo.png
//               width: 150,
//               height: 150,
//             ),
//             const SizedBox(height: 20),
//             CircularProgressIndicator(
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Loading...',
//               style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
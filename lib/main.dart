import 'package:abgbale/screens/launch/splash.dart';
import 'package:abgbale/screens/launch/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:abgbale/screens/auth/login.dart'; // Import LoginScreen
import 'package:abgbale/screens/dashboard/tableau.dart'; // Import TableauScreen
import 'package:abgbale/utils/token_manager.dart'; // Import TokenManager

void main() {
  runApp(const MyApp());
  
}


class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0206A6); // Blue
    const secondaryColor = Color(0xFFFFC905); // Golden Yellow

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'Agbale App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          brightness: Brightness.light,
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        cardTheme: Theme.of(context).cardTheme.copyWith(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

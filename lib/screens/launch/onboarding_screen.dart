import 'package:flutter/material.dart';
import 'package:abgbale/screens/auth/login.dart'; // Assuming login is the next step after onboarding

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
  
}


class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
   {
      'image': 'assets/onboarding1.png',
      'title': 'Welcome to Agbale',
      'description':  'Your all-in-one solution for managing contacts, notes, and more.',
    },
    {
      'image': 'assets/onboarding2.png',
      'title': 'Stay Organized',
      'description': ' Easily create and track your notes and to-do lists.',
    },
    {
      'image': 'assets/onboarding3.png',
      'title': ' Connect Seamlessly',
      'description': ' Manage your contacts and social media links in one place',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // backgroundColor: Colors.white,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPage(
                image: onboardingData[index]['image']!,
                title: onboardingData[index]['title']!,
                description: onboardingData[index]['description']!,
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentPage != onboardingData.length - 1
                      ? TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onBackground,
                          ),
                          child: Text('Passer', style: TextStyle(fontSize: 16, color: Colors.white)),
                        )
                      : const SizedBox.shrink(),
                  Row(
                    children: List.generate(
                      onboardingData.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                  _currentPage != onboardingData.length - 1
                      ? FloatingActionButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.ease,
                            );
                          },
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          child: const Icon(Icons.arrow_forward),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: const Text('Commencer',style: TextStyle(fontSize: 13, color: Colors.white),textAlign: TextAlign.center),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.8), // Semi-transparent black overlay
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(image, height: 250), // Removed as it's now background
            const SizedBox(height: 30),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // Changed to white for visibility
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                description,
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)), // Changed to white for visibility
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
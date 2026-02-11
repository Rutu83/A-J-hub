// lib/onboarding_screen.dart

import 'package:ajhub_app/arth_screens/login_screen.dart';
import 'package:ajhub_app/arth_screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The main stateful widget for the onboarding screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data for the onboarding pages using your provided images.
  final List<String> _onboardingImages = [
    "assets/images/onboarding_1.jpg",
    "assets/images/onboarding_2.jpg",
    "assets/images/onboarding_3.jpg",
    "assets/images/onboarding_4.jpg",
  ];

  /// Marks onboarding as complete and navigates to the chosen auth screen.
  void _completeOnboarding(Widget destination) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color pageBackgroundColor = Colors.red;
    final int totalPages =
        _onboardingImages.length + 1; // Add 1 for the final choice page

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      body: Stack(
        children: [
          // Layer 1: The PageView with images and the final choice screen
          PageView.builder(
            controller: _pageController,
            // The total number of pages is images + 1 final page
            itemCount: totalPages,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              // If the index is for the final page, show the choice screen
              if (index == _onboardingImages.length) {
                return _buildFinalChoicePage(context, pageBackgroundColor);
              }
              // Otherwise, show the onboarding image
              return Image.asset(
                _onboardingImages[index],
                fit: BoxFit.fill,
                height: double.infinity,
                width: double.infinity,
              );
            },
          ),

          // Layer 2: The controls (dots and button), hidden on the last page
          // We check if the current page is one of the image pages.
          if (_currentPage < _onboardingImages.length)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingImages
                            .length, // Only show dots for image pages
                        (index) => buildDot(index),
                      ),
                    ),
                    // Next Button
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            color: pageBackgroundColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the final page where the user chooses to Login or Register.
  Widget _buildFinalChoicePage(BuildContext context, Color bgColor) {
    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.rocket_launch_outlined, // A more dynamic icon for growth
            color: Colors.white,
            size: 100,
          ),
          const SizedBox(height: 24),
          const Text(
            'You are all set!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),

          // --- Registration Option (UPDATED CONTENT) ---
          const Text(
            'Grow Your Business with AjHub', // New, benefit-focused headline
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // New descriptive text
            'Create an account to promote your business and enjoy the ajhub experience!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white
                  .withOpacity(0.85), // Slightly more opaque for readability
              fontSize: 15, // Slightly larger font
              height: 1.4, // Improved line spacing
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _completeOnboarding(const SignUpScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Start Growing', // New, action-oriented button text
              style: TextStyle(
                fontSize: 16,
                color: bgColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // --- Login Option (No changes needed here) ---
          const Text(
            'Already have an account?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log in to access your existing data and continue where you left off.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _completeOnboarding(const LoginScreen()),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.white, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget for building the page indicator dots.
  AnimatedContainer buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 10,
      width: _currentPage == index ? 25 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Colors.white
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

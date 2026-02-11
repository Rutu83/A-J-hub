import 'dart:async';

import 'package:ajhub_app/arth_screens/login_screen.dart';
import 'package:ajhub_app/screens/dashbord_screen.dart';
import 'package:ajhub_app/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  static const String keyLogin = 'login';
  static const String keyOnboardingComplete = 'onboardingComplete';

  // This will hold the business ID found in SharedPreferences at the start.
  int? _initialSelectedBusinessId;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward().then((_) {
      _initializeApp();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // 3. Determine where to navigate based on login and onboarding status.
    var sharePref = await SharedPreferences.getInstance();
    var isLoggedIn = sharePref.getBool(keyLogin) ?? false;
    final bool hasSeenOnboarding =
        sharePref.getBool(keyOnboardingComplete) ?? false;

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(360, 690), minTextAdapt: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            FadeTransition(
              opacity: _fadeInAnimation,
              child: Image.asset('assets/images/app_logo.png', height: 220.h),
            ),
            const Spacer(),
            FadeTransition(
              opacity: _fadeInAnimation,
              child: Text('Version 3.0.0',
                  style: TextStyle(fontSize: 14.sp, color: Colors.red)),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

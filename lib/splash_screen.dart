import 'dart:async';
import 'package:allinone_app/arth_screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  static  const String keyLogin = 'login';
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
      // After animation completes, navigate to the login screen
      //_navigateToLoginScreen();

      varToGo();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void varToGo() async{

    var  sharePref =await SharedPreferences.getInstance();

    var isloggedIn  =  sharePref.getBool(keyLogin);

    Timer (const Duration (seconds:2),() {
      if (isloggedIn != null) {
        if (isloggedIn) {
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => const LoginScreen()));
        }
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    }

    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690), minTextAdapt: true);
    return Scaffold(
  //    backgroundColor: const Color(0xFF023b8a),

      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            FadeTransition(
              opacity: _fadeInAnimation,
              child: Image.asset(
                'assets/images/allinonenews.jpg',
                height: 220.h,
              ),
            ),
            const Spacer(),
            FadeTransition(
              opacity: _fadeInAnimation,
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

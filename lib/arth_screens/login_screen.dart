// ignore_for_file: use_build_context_synchronously

import 'package:allinone_app/arth_screens/auth_admin_service.dart';
import 'package:allinone_app/arth_screens/signup_screen.dart';
import 'package:allinone_app/screens/dashbord_screen.dart';
import 'package:allinone_app/splash_screen.dart';
import 'package:allinone_app/utils/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? fcmToken;
  bool isRemember = true;
  bool _isLoding = false;
  late AnimationController _animationController;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin({bool isDirectLogin = false}) {
    if (isDirectLogin) {
      _handleLoginAdmin();
    } else {
      hideKeyboard(context);
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        _handleLoginAdmin();
      }
    }
  }

  void _handleLoginAdmin() async {
    setState(() {
      _isLoding = true;
    });

    hideKeyboard(context);
    Map<String, String> request = {
      'email': _phoneController.text.trim(),
      'password': _passwordController.text.trim(),
    };

    log(request);

    await loginCurrentAdminMobile(context, req: request).then((value) async {

      saveDataToAdminPreferenceMobile(context,
          loginResponse: value,
          parentUserData: value.userData!, onRedirectionClick: () {
            setState(() {
              _isLoding = false;
            });


            onLoginSuccessRedirection();
          });
      if (isRemember) {

        setValue(USER_EMAIL, _phoneController.text);
        setValue(USER_PASSWORD, _passwordController.text);
        await setValue(IS_REMEMBERED, isRemember);
      }
    }).catchError((e) {
      setState(() {
        _isLoding = false;
      });
      String error = e.toString();
      onLoginerror(error);
    });
  }

  Future<void> onLoginerror(String error) async {
    setState(() {
      _isLoding = false;
    });

    Fluttertoast.showToast(
        msg: error,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );

    // const DashboardScreen().launch(context,
    //     isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
  }

  Future<void> onLoginSuccessRedirection() async {

    var pref = await SharedPreferences.getInstance();
    pref.setBool(SplashScreenState.keyLogin, true);
    if (kDebugMode) {
      print(',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,');
    }
    const DashboardScreen().launch(context,
        isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
  }

  @override
  Widget build(BuildContext context) {






    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100.h,
              ),

              Image.asset(
                'assets/images/aj3.jpg',
                height: 150.h,
                width: 180.h,
              ),
              Text(
                'Welcome to All In One App',
                style: GoogleFonts.aBeeZee(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoding ? null : () => _handleLogin(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoding
                    ? const CircularProgressIndicator()
                    : const Text('Login', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Handle "Forgot Password" logic
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xFFFF0000)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 46.h,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(context, (MaterialPageRoute(builder: (context) =>const SignUpScreen())));

                // Navigate to login screen or other appropriate action
              },
              child: Text(
                "Already have an account? Login",
                style: GoogleFonts.aclonica(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF0000),
                ),
              ),
            ),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.aclonica(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

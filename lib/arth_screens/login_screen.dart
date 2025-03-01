import 'dart:convert';
import 'package:ajhub_app/arth_screens/auth_admin_service.dart';
import 'package:ajhub_app/arth_screens/signup_screen.dart';
import 'package:ajhub_app/screens/dashbord_screen.dart';
import 'package:ajhub_app/screens/forgot_screen.dart';
import 'package:ajhub_app/splash_screen.dart';
import 'package:ajhub_app/utils/constant.dart';
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
  bool _isLoading = false;
  late AnimationController _animationController;
  bool _isPasswordVisible = false;

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
      _isLoading = true;
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
              _isLoading = false;
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
        _isLoading = false;
      });
      String error = e.toString();
      if (error.contains("Token is Expired")) {
        error = "Invalid email or password.";
      }
      onLoginError(error);
    });
  }


  Future<void> onLoginError(String error) async {
    setState(() {
      _isLoading = false;
    });

    String errorMessage = 'An unexpected error occurred.';
    try {

      final errorResponse = json.decode(error);
      if (errorResponse['message'] != null) {
        errorMessage = errorResponse['message'];
      }
    } catch (e) {
      errorMessage = error;
    }

    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }


  Future<void> onLoginSuccessRedirection() async {
    var pref = await SharedPreferences.getInstance();
    pref.setBool(SplashScreenState.keyLogin, true);
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
              SizedBox(height: 100.h),

              Image.asset(
                'assets/images/app_logo2.png',
                height: 150.h,
                width: 180.h,
              ),
              Text(
                'Welcome To Aj Hub App',
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
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
                onPressed: _isLoading ? null : () => _handleLogin(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    :  Text('Login',
                  style: GoogleFonts.roboto(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: GoogleFonts.roboto(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )


            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 90.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: Text(
                    "New to Our App?",
                    style: GoogleFonts.roboto(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFF0000),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),

                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000),
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      "Join Now",
                      style: GoogleFonts.lato(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),


            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.aclonica(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Powered by - All in One',
              style: GoogleFonts.aclonica(
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),

    );
  }

}


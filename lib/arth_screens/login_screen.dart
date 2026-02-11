import 'dart:convert';

import 'package:ajhub_app/arth_screens/auth_admin_service.dart';
import 'package:ajhub_app/arth_screens/signup_screen.dart';
import 'package:ajhub_app/main.dart'; // --- ADDED: For appStore.token ---
import 'package:ajhub_app/screens/dashbord_screen.dart';
import 'package:ajhub_app/screens/forgot_screen.dart';
import 'package:ajhub_app/splash_screen.dart';
import 'package:ajhub_app/utils/configs.dart'; // --- ADDED: For BASE_URL ---
import 'package:ajhub_app/utils/constant.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // --- ADDED: For kDebugMode ---
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // --- ADDED: For API calls ---
import 'package:nb_utils/nb_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
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
    _initFCMToken();
  }

  void _initFCMToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    log('FCM Token: $fcmToken');
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
      'fcm_token': fcmToken ?? '',
    };

    log(request);

    await loginCurrentAdminMobile(context, req: request).then((value) async {
      // --- MODIFIED: The success callback is now async to handle the business fetch ---
      saveDataToAdminPreferenceMobile(context,
          loginResponse: value,
          parentUserData: value.userData!, onRedirectionClick: () async {
        // --- ADDED: Fetch and set the initial business profile silently ---
        await _fetchAndSetInitialBusiness();

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

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

  // --- ADDED: Method to fetch businesses and set the first one as active ---
  Future<void> _fetchAndSetInitialBusiness() async {
    // We already know the user is logged in and token is stored in appStore
    const apiUrl = '${BASE_URL}getbusinessprofile';
    String token = appStore.token;

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        if (data is List && data.isNotEmpty) {
          // If businesses exist, take the first one and store it
          final firstBusiness = data.first;
          await _storeActiveBusiness(firstBusiness);
          if (kDebugMode) {
            print(
                'Login Success: Set "${firstBusiness['business_name']}" as active business.');
          }
        } else {
          // If user has no businesses, clear any old data
          await _clearActiveBusiness();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("LoginScreen: Silent error fetching business data: $e");
        // We don't show an error to the user, login should proceed.
      }
    }
  }

  // --- ADDED: Helper method to save the active business to SharedPreferences ---
  Future<void> _storeActiveBusiness(Map<String, dynamic> business) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (business['id'] == null) return;

    await prefs.setInt('selected_business_id', business['id']);
    await prefs.setString(
        'active_business_name', business['business_name'] ?? 'No Name');
    await prefs.setString('active_business_logo', business['logo'] ?? '');
    await prefs.setString(
        'active_business_owner_photo', business['personal_photo'] ?? '');
    await prefs.setString('active_business', json.encode(business));
  }

  // --- ADDED: Helper to clear business data if none are found ---
  Future<void> _clearActiveBusiness() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_business_id');
    await prefs.remove('active_business');
    await prefs.remove('active_business_name');
    await prefs.remove('active_business_logo');
    await prefs.remove('active_business_owner_photo');
    if (kDebugMode) {
      print(
          "LoginScreen: Cleared active business data because no businesses were found.");
    }
  }

  Future<void> onLoginError(String error) async {
    // ... (This function remains unchanged)
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
    // ... (This function remains unchanged)
    var pref = await SharedPreferences.getInstance();
    pref.setBool(SplashScreenState.keyLogin, true);
    const DashboardScreen().launch(context,
        isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
  }

  @override
  Widget build(BuildContext context) {
    // --- The entire build method remains UNCHANGED ---
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
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
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
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
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
                    const SizedBox(height: 6),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.roboto(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
                    : Text(
                        'Login',
                        style: GoogleFonts.roboto(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 46),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
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
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 18.0),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 85.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text(
              'Version 3.0.0',
              style: GoogleFonts.aclonica(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Powered by - All in One Marketing Service',
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

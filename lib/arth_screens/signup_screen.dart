import 'dart:convert';

// <<< --- IMPORTS ADDED FOR AUTO-LOGIN --- >>>
import 'package:ajhub_app/arth_screens/auth_admin_service.dart';
import 'package:ajhub_app/model/login_modal.dart';
import 'package:ajhub_app/screens/dashbord_screen.dart';
import 'package:ajhub_app/splash_screen.dart';
// ---

import 'package:ajhub_app/utils/configs.dart';
import 'package:ajhub_app/utils/notification_service.dart';
import 'package:ajhub_app/utils/referral_service.dart';
import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  // --- CONTROLLERS AND KEYS ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _searchStateController = TextEditingController();
  final TextEditingController _searchCityController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  // --- STATE VARIABLES ---
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  List<dynamic> filteredCountries = [];
  List<dynamic> filteredStates = [];
  List<dynamic> filteredCities = [];
  bool isLocationError = false;
  bool _isPhoneNumberValid = true;
  bool _isPasswordValid = true;
  bool _isEmailValid = true;
  String? selectedCountry;
  String? selectedState; // For displaying the name in the UI
  String? selectedCity; // For displaying the name in the UI
  String? selectedStateId; // To store the state ID for the API
  String? selectedCityId; // To store the district ID for the API
  bool _passwordsMatch = true;
  List<dynamic> countries = [];
  List<dynamic> states = [];
  List<dynamic> cities = [];
  String selectedCountryCode = '+91';
  bool _isLoading = false;
  bool _isLoadingCountries = false;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;

  // --- REFERRAL LOGIC VARIABLES ---
  bool _isVerifyingReferral = false;
  String? _verifiedReferrerId;
  String? _verifiedReferrerUsername;

  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    fetchCountries();
    filteredStates = states;
    filteredCities = cities;

    _passwordController.addListener(_checkPasswords);
    _confirmPasswordController.addListener(_checkPasswords);
    _phoneController.addListener(_validatePhoneNumber);
    _emailController.addListener(_validateEmail);

    _referralCodeController.addListener(() {
      final code = _referralCodeController.text;
      if (code.length >= 4 && !_isVerifyingReferral) {
        _fetchUserByReferralCode(code);
      }
    });

    _initializeReferralCode();
    _initializeFCM();
  }

  @override
  void dispose() {
    _referralCodeController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _confirmPasswordController.dispose();
    _searchStateController.dispose();
    _searchCityController.dispose();
    super.dispose();
  }

  // --- LOGIC METHODS ---

  // <<< NEW HELPER FUNCTION FOR REDIRECTION >>>
  Future<void> _onRegistrationSuccessRedirect() async {
    await setValue(SplashScreenState.keyLogin, true);

    if (mounted) {
      const DashboardScreen().launch(context,
          isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }
  }

  Future<void> _initializeFCM() async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final String? token = await fcm.getToken();
    if (mounted) setState(() => _fcmToken = token);
    print("Firebase Messaging Token: $_fcmToken");
  }

  Future<void> _registerUser() async {
    if (selectedCountry == null ||
        selectedStateId == null ||
        selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select Country, State, and District')));
      setState(() => isLocationError = true);
      return;
    }

    if (_fcmToken == null || _fcmToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Could not initialize notifications. Please check your connection and restart the app.'),
        backgroundColor: Colors.red,
      ));
      await _initializeFCM();
      if (_fcmToken == null) return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      const String apiUrl = '${BASE_URL}register';
      final Map<String, dynamic> payload = {
        "username": _firstNameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone_number": _phoneController.text.trim(),
        "password": _passwordController.text.trim(),
        "password_confirmation": _confirmPasswordController.text.trim(),
        "country_id": selectedCountry,
        // <<< PAYLOAD FIX: Use 'state_id' and 'district_id' as per the API >>>
        "state_id": selectedStateId,
        "district_id": selectedCityId,
        "parentId": _verifiedReferrerId,
        "sponcer_id": _verifiedReferrerId,
        "fcm_token": _fcmToken,
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: json.encode(payload),
        );

        if (!mounted) return;

        // <<< --- MAJOR UPDATE: AUTO-LOGIN LOGIC --- >>>
        if (response.statusCode == 201) {
          final responseData = json.decode(response.body);

          // 1. Parse the API response using your existing LoginResponse model.
          final loginResponse = LoginResponse.fromJson(responseData);

          // 2. Save session data using the function from your login screen.
          await saveDataToregisterPreferenceMobile(
            context,
            loginResponse: loginResponse,
            parentUserData: loginResponse.userData!,
            onRedirectionClick: () async {
              // 3. (Optional) Show a local welcome notification.
              await NotificationService().showWelcomeNotification(
                  username: loginResponse.userData!.username!);

              // 4. Redirect to the dashboard.
              _onRegistrationSuccessRedirect();
            },
          );
        } else {
          // Handle errors from the API
          final responseData = json.decode(response.body);
          final errors = responseData['errors'] as Map<String, dynamic>?;
          String errorMessage =
              'An unexpected error occurred. Please try again.';

          if (errors != null) {
            errorMessage = errors.values
                .expand((errorList) => errorList as List)
                .join('\n');
          } else if (responseData['message'] != null) {
            errorMessage = responseData['message'];
          }

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(errorMessage), backgroundColor: Colors.red));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Network error. Please check your connection.')));
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // --- ALL OTHER METHODS BELOW THIS LINE ARE UNCHANGED ---

  Future<void> _initializeReferralCode() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    String? installReferrerCode =
        await ReferralService.getInstallReferrerCode();
    if (installReferrerCode != null && installReferrerCode.isNotEmpty) {
      _referralCodeController.text = installReferrerCode;
      await _fetchUserByReferralCode(installReferrerCode);
      return;
    }

    if (_referralCodeController.text.isEmpty) {
      await _checkClipboardForReferralCode();
    }
  }

  Future<void> _checkClipboardForReferralCode() async {
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null) {
        String clipboardText = data.text!.trim();
        RegExp referralPattern = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

        if (referralPattern.hasMatch(clipboardText)) {
          if (!mounted) return;
          _referralCodeController.text = clipboardText;
          await _fetchUserByReferralCode(clipboardText);
        }
      }
    } catch (e) {
      print("Could not read from clipboard: $e");
    }
  }

  void _showReferralSnackbar(String name, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referrer "$name" $message'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _fetchUserByReferralCode(String code) async {
    if (code.trim().isEmpty) {
      setState(() {
        _verifiedReferrerId = null;
        _verifiedReferrerUsername = null;
      });
      return;
    }

    setState(() {
      _isVerifyingReferral = true;
      _verifiedReferrerId = null;
    });

    try {
      final uri = Uri.parse('${BASE_URL}search-user?query=$code');
      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty && data[0]['referral_code'] == code) {
          final user = data[0];
          setState(() {
            _verifiedReferrerId = user['userId'].toString();
            _verifiedReferrerUsername = user['username'].toString();
          });
          _showReferralSnackbar(
              _verifiedReferrerUsername!, "applied successfully!");
        } else {
          setState(() => _verifiedReferrerId = null);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Invalid or incorrect referral code.'),
            backgroundColor: Colors.orange,
          ));
        }
      } else {
        setState(() => _verifiedReferrerId = null);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error verifying referral code. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _verifiedReferrerId = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Network error. Could not verify code.'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingReferral = false;
        });
      }
    }
  }

  void fetchCountries() async {
    setState(() {
      _isLoadingCountries = true;
    });
    try {
      final response = await http.get(Uri.parse('${BASE_URL}get-country'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            countries = json.decode(response.body);
            filteredCountries = countries;
            _isLoadingCountries = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCountries = false;
        });
      }
    }
  }

  void fetchStates(String countryId) async {
    setState(() {
      _isLoadingStates = true;
      selectedState = null;
      selectedCity = null;
      selectedStateId = null;
      selectedCityId = null;
    });
    try {
      final response = await http.get(
          Uri.parse('https://ajhub.co.in/get-states-regby-country/$countryId'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            states = json.decode(response.body);
            filteredStates = states;
            _isLoadingStates = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStates = false;
        });
      }
    }
  }

  void fetchCities(String stateId) async {
    setState(() {
      _isLoadingCities = true;
      selectedCity = null;
      selectedCityId = null;
    });
    try {
      final response = await http.get(
          Uri.parse('https://ajhub.co.in/get-districts-regby-state/$stateId'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            cities = json.decode(response.body);
            filteredCities = cities;
            _isLoadingCities = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCities = false;
        });
      }
    }
  }

  void _validateEmail() {
    setState(() {
      _isEmailValid = _isValidEmail(_emailController.text);
    });
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegExp.hasMatch(email);
  }

  void _checkPasswords() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
      _isPasswordValid = _passwordController.text.length >= 6;
    });
  }

  void _validatePhoneNumber() {
    setState(() {
      _isPhoneNumberValid = _phoneController.text.isNotEmpty &&
          _isValidPhoneNumber(_phoneController.text);
    });
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    final phoneRegExp = RegExp(r'^\+?\d{10,15}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        _buildAppLogo(),
                        SizedBox(height: 10.h),
                        _buildTextField('First Name', 'Enter First Name', true,
                            _firstNameController),
                        SizedBox(height: 10.h),
                        _buildEmailField(),
                        SizedBox(height: 10.h),
                        _buildPhoneNumberField(),
                        SizedBox(height: 10.h),
                        _buildCountryField(),
                        SizedBox(height: 10.h),
                        _buildStateField(),
                        SizedBox(height: 10.h),
                        _buildCityField(),
                        SizedBox(height: 10.h),
                        _buildPasswordField(),
                        SizedBox(height: 10.h),
                        _buildConfirmPasswordField(),
                        if (!_passwordsMatch)
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text('Passwords do not match',
                                style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 12.sp)),
                          ),
                        SizedBox(height: 10.h),
                        TextFormField(
                          controller: _referralCodeController,
                          decoration: InputDecoration(
                            labelText: 'Referral Code (Optional)',
                            hintText: 'Enter referral code',
                            prefixIcon:
                                Icon(Icons.group_add, color: Colors.grey[600]),
                            suffixIcon: _isVerifyingReferral
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.0),
                                    ),
                                  )
                                : _verifiedReferrerId != null
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : null,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            labelStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Sign Up',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text("Sign In",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // --- BUILD WIDGETS ---

  Widget _buildAppLogo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Image.asset('assets/images/app_logo2.png',
          height: 120.h, width: 120.h, fit: BoxFit.cover),
    );
  }

  Widget _buildTextField(String label, String hint, bool isRequired,
      TextEditingController controller,
      {bool isMultiline = false,
      bool enabled = true,
      TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: isMultiline ? null : 1,
      enabled: enabled,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$label can\'t be empty';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        labelStyle: const TextStyle(color: Colors.black),
        errorStyle: TextStyle(color: Colors.red.shade900, fontSize: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red.shade900)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red.shade900)),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter Your Email',
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.grey.shade400)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
                color: _isEmailValid
                    ? Colors.grey.shade400
                    : Colors.red.shade900)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
                color: _isEmailValid ? Colors.black : Colors.red.shade900)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.red.shade900)),
        errorText: _isEmailValid ? null : 'Please enter a valid email address',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!_isValidEmail(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: true,
                  onSelect: (Country country) {
                    setState(() {
                      selectedCountryCode = '+${country.phoneCode}';
                    });
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: _isPhoneNumberValid
                          ? Colors.grey.shade400
                          : Colors.red.shade900),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Text(selectedCountryCode,
                        style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                                color: Colors.black, fontSize: 12.sp))),
                    const Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w400)),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade400)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                          color: _isPhoneNumberValid
                              ? Colors.grey.shade400
                              : Colors.red)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                          color:
                              _isPhoneNumberValid ? Colors.black : Colors.red)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.red.shade900)),
                  errorText: _isPhoneNumberValid
                      ? null
                      : 'Please enter a valid phone number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        labelStyle: TextStyle(
            color: _passwordsMatch ? Colors.black : Colors.red.shade900),
        errorText: !_isPasswordValid
            ? 'Password must be at least 6 characters long'
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: _isPasswordValid ? Colors.grey : Colors.red.shade900)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: _isPasswordValid ? Colors.black : Colors.red.shade900)),
        suffixIcon: IconButton(
          icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey),
          onPressed: () => setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          }),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your password';
        if (value.length < 6)
          return 'Password must be at least 6 characters long';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter your password',
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        labelStyle: TextStyle(
            color: _passwordsMatch ? Colors.black : Colors.red.shade900),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: _passwordsMatch ? Colors.grey : Colors.red.shade900)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: _passwordsMatch ? Colors.grey : Colors.red.shade900)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: _passwordsMatch ? Colors.black : Colors.red.shade900)),
        suffixIcon: IconButton(
          icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.grey),
          onPressed: () => setState(() {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          }),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty)
          return 'Please confirm your password';
        if (value != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }

  Widget _buildCountryField() {
    return GestureDetector(
      onTap: () => _showCountrySelectionSheet(),
      child: Container(
        height: 45.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: isLocationError && selectedCountry == null
                  ? Colors.red.shade900
                  : Colors.grey.shade400,
              width: 1.5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _isLoadingCountries
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                        width: 150.w, height: 12.h, color: Colors.white),
                  )
                : Text(
                    selectedCountry != null
                        ? countries.firstWhere((c) =>
                            c['id'].toString() == selectedCountry)['name']
                        : 'Select Country',
                    style: GoogleFonts.roboto(
                        textStyle:
                            TextStyle(color: Colors.black, fontSize: 12.sp))),
            const Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildStateField() {
    return GestureDetector(
      onTap: () => _showStateSelectionSheet(),
      child: Container(
        height: 45.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: isLocationError && selectedState == null
                  ? Colors.red.shade900
                  : Colors.grey.shade400,
              width: 1.5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _isLoadingStates
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                        width: 150.w, height: 12.h, color: Colors.white),
                  )
                : Text(selectedState != null ? selectedState! : 'Select State',
                    style: GoogleFonts.roboto(
                        textStyle:
                            TextStyle(color: Colors.black, fontSize: 12.sp))),
            const Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildCityField() {
    return GestureDetector(
      onTap: () => _showCitySelectionSheet(),
      child: Container(
        height: 45.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: isLocationError && selectedCity == null
                  ? Colors.red.shade900
                  : Colors.grey.shade400,
              width: 1.5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _isLoadingCities
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                        width: 150.w, height: 12.h, color: Colors.white),
                  )
                : Text(selectedCity != null ? selectedCity! : 'Select District',
                    style: GoogleFonts.roboto(
                        textStyle:
                            TextStyle(color: Colors.black, fontSize: 12.sp))),
            const Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
    );
  }

  void _showCountrySelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0))),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                      height: 6,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12))),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Select Country',
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: countries.length,
                      itemBuilder: (context, index) {
                        final country = countries[index];
                        return ListTile(
                          title: Text(country['name']),
                          onTap: () {
                            setState(() {
                              selectedCountry = country['id'].toString();
                            });
                            fetchStates(selectedCountry!);
                            Navigator.pop(context);
                          },
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const Divider(thickness: 1, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStateSelectionSheet() {
    if (selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a country first')));
      return;
    }
    _showSearchableModal(
      title: 'State',
      searchController: _searchStateController,
      items: states,
      onItemSelected: (selectedStateItem) {
        setState(() {
          selectedState = selectedStateItem['name'];
          selectedStateId = selectedStateItem['id'].toString();
          selectedCity = null;
          selectedCityId = null;
        });
        fetchCities(selectedStateId!);
      },
    );
  }

  void _showCitySelectionSheet() {
    if (selectedStateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a state first')));
      return;
    }
    _showSearchableModal(
      title: 'District',
      searchController: _searchCityController,
      items: cities,
      onItemSelected: (selectedCityItem) {
        setState(() {
          selectedCity = selectedCityItem['name'];
          selectedCityId = selectedCityItem['id'].toString();
        });
      },
    );
  }

  void _showSearchableModal(
      {required String title,
      required TextEditingController searchController,
      required List<dynamic> items,
      required Function(Map<String, dynamic>) onItemSelected}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
      builder: (BuildContext context) {
        List<dynamic> filteredItems = List.from(items);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.sp)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search $title',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (query) {
                          setModalState(() {
                            filteredItems = items
                                .where((item) => item['name']
                                    .toString()
                                    .toLowerCase()
                                    .contains(query.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return ListTile(
                            title: Text(item['name']),
                            onTap: () {
                              onItemSelected(item);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

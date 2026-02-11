import 'dart:convert';
import 'package:ajhub_app/arth_screens/login_screen.dart';
import 'package:ajhub_app/utils/configs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool _isFormValid = false;
  bool _isSubmitted = false; // ✅ Track if the form has been submitted

  // ✅ Function to Check Form Validation and Update Button State
  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> sendResetLink() async {
    setState(() {
      _isSubmitted = true; // ✅ Mark form as submitted
    });

    if (!_formKey.currentState!.validate()) {
      return; // ✅ Prevent API call if form validation fails
    }

    if (isLoading) return; // ✅ Prevent multiple clicks

    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String confirm = confirmPasswordController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${BASE_URL}reset-password'),
        headers: {'Content-Type': 'application/json'}, // ✅ Proper API request format
        body: jsonEncode({
          'email': email,
          'password': password,
          'password_confirmation': confirm,
        }),
      );

      // ✅ Print full response for debugging (only in debug mode)
      if (kDebugMode) {
        print("🔄 API Request to: ${BASE_URL}reset-password");
        print("📧 Email: $email");
        print("📝 Password: ${'*' * password.length}"); // Hide actual password for security
        print("📝 Confirm Password: ${'*' * confirm.length}");
        print("🟢 Response Status: ${response.statusCode}");
        print("📜 Response Body: ${response.body}");
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          _isFormValid = false; // Disable button after success
          _isSubmitted = false; // Reset submission state
        });

        Navigator.pushReplacement(context, (MaterialPageRoute(builder: (context)=>const LoginScreen())));
        showSnackBar(
          responseData['message'] ?? "✅ Password reset successfully.",
          Colors.green,
        );



      }
      else {
        handleErrorResponse(response);
      }
    } catch (e) {
      // ✅ Print error for debugging
      if (kDebugMode) {
        print("❌ Network or Parsing Error: $e");
      }
      showSnackBar("🚨 Network error occurred. Please try again.", Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  void handleErrorResponse(http.Response response) {
    try {
      final Map<String, dynamic> errorResponse = jsonDecode(response.body);
      String errorMessage = "An unknown error occurred.";

      // ✅ Print full error response for debugging
      if (kDebugMode) {
        print("❌ Error Status Code: ${response.statusCode}");
        print("❌ Error Response Body: ${response.body}");
      }

      if (response.statusCode == 400) {
        errorMessage = "⚠️ Invalid request. Please check your input.";
      } else if (response.statusCode == 401) {
        errorMessage = "🔒 Unauthorized! Please check your credentials.";
      } else if (response.statusCode == 403) {
        errorMessage = "🚫 Access Denied! You don’t have permission.";
      } else if (response.statusCode == 404) {
        errorMessage = "🔍 Endpoint not found! Check API URL.";
      } else if (response.statusCode == 422) {
        errorMessage = extractValidationErrors(errorResponse);
      } else if (response.statusCode == 500) {
        errorMessage = "💥 Server error! Please try again later.";
      } else if (errorResponse.containsKey('message')) {
        errorMessage = errorResponse['message'];
      }

      showSnackBar(errorMessage, Colors.red);
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ JSON Parsing Error: $e");
      }
      showSnackBar("⚠️ Unexpected error occurred. Please try again.", Colors.red);
    }
  }

  String extractValidationErrors(Map<String, dynamic> errorResponse) {
    if (errorResponse.containsKey('error') && errorResponse['error'] is Map) {
      final errors = errorResponse['error'] as Map<String, dynamic>;
      List<String> errorMessages = [];

      for (var key in errors.keys) {
        if (errors[key] is List) {
          errorMessages.add("${errors[key][0]}"); // Get first error for each field
        } else if (errors[key] is String) {
          errorMessages.add(errors[key]);
        }
      }

      return errorMessages.join("\n"); // Combine all errors in a single message
    }
    return "⚠️ Validation failed. Please check your input.";
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isPassword,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: controller,
                    obscureText: isPassword ? !isPasswordVisible : false,
                    keyboardType: keyboardType,
                    autovalidateMode: _isSubmitted
                        ? AutovalidateMode.always // ✅ Show validation errors only after first submit
                        : AutovalidateMode.disabled,
                    onChanged: (_) => _validateForm(), // ✅ Update button state on text change
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(icon, color: Colors.red),
                      suffixIcon: isPassword
                          ? IconButton(
                        icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      )
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "⚠️ Required";
                      if (isPassword) {
                        if (value.length < 8) return "⚠️ Min 8 chars";
                        if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) return "⚠️ 1 Uppercase";
                        if (!RegExp(r'(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~])').hasMatch(value)) return "⚠️ 1 Special Char";
                      }
                      if (label.contains("Confirm Password") && value != passwordController.text) {
                        return "⚠️ Passwords do not match";
                      }
                      return null;
                    },
                  ),
                ),

                // **Right-Aligned Error Message (Only Show if Submitted)**
                if (_isSubmitted)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, right: 10),
                      child: Builder(
                        builder: (context) {
                          String? errorText;
                          String value = controller.text.trim();
                          if (value.isEmpty) {
                            errorText = "⚠️ Required";
                          } else if (isPassword) {
                            if (value.length < 6) {
                              errorText = "⚠️ Min 6 chars";
                            } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                              errorText = "⚠️ 1 Uppercase";
                            } else if (!RegExp(r'(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~])').hasMatch(value)) {
                              errorText = "⚠️ 1 Special Char";
                            }
                          }
                          if (label.contains("Confirm Password") && value != passwordController.text) {
                            errorText = "⚠️ Not matching";
                          }
                          return errorText != null
                              ? Text(errorText, style: GoogleFonts.poppins(fontSize: 14, color: Colors.red, fontWeight: FontWeight.w500))
                              : const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.redAccent, Colors.pinkAccent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 6,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/f_pass.jpg', height: 100),
                    const SizedBox(height: 20),
                    Text("Reset Your Password", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                    const Divider(color: Colors.red),
                    const SizedBox(height: 10),
                    Text("Enter your email and create a new password to reset your account.", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16)),
                    const SizedBox(height: 20),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(label: "📧 Email Address *", controller: emailController, icon: Icons.email, isPassword: false, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildTextField(label: "🔑 New Password *", controller: passwordController, icon: Icons.lock, isPassword: true, keyboardType: TextInputType.visiblePassword),
                          const SizedBox(height: 16),
                          _buildTextField(label: "🔄 Confirm Password *", controller: confirmPasswordController, icon: Icons.lock, isPassword: true, keyboardType: TextInputType.visiblePassword),
                          const SizedBox(height: 30),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300), // Smooth transition
                            child: isLoading
                                ? const CircularProgressIndicator() // Show loader when processing
                                : AnimatedOpacity(
                              duration: const Duration(milliseconds: 300), // Smooth fade-in effect
                              opacity: _isFormValid ? 1.0 : 0.5, // Dim button when disabled
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isFormValid ? sendResetLink : null, // ✅ Disable if form is invalid
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isFormValid ? Colors.redAccent : Colors.grey, // Color changes when disabled
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12), // Rounded corners
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: _isFormValid ? 5 : 0, // Remove shadow when disabled
                                  ),
                                  child: Text(
                                    "🔄 Reset Password",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

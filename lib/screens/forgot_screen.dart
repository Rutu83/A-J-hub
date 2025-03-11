import 'dart:convert';
import 'package:ajhub_app/utils/configs.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
   ForgotPasswordScreenState createState() =>  ForgotPasswordScreenState();
}

class  ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;


  Future<void> sendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String email = emailController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${BASE_URL}forget-password'),
        body: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          emailController.clear();
          // phoneController.clear();
        });
        final Map<String, dynamic> messageResponse = jsonDecode(response.body);
        String successMessage = messageResponse['message'] ?? "Password reset link sent to your email.";

        showDialog(
              context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Success", style: GoogleFonts.poppins()),
              content: Text(successMessage, style: GoogleFonts.poppins()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK", style: GoogleFonts.poppins()),
                ),
              ],
            );
          },
        );
      } else {
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        String errorMessage = errorResponse['error'] ?? "An unknown error occurred.";

        showErrorDialog(errorMessage);
      }
    } catch (e) {
      showErrorDialog("An error occurred: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error", style: GoogleFonts.poppins()),
          content: Text(message, style: GoogleFonts.poppins()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          "Forgot Password",
          style: GoogleFonts.poppins(color: Colors.white,fontSize: 20),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/forgot_password.jpg',
                  height: 150,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Forgot Password Request",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const Divider(color: Colors.red),
              const SizedBox(height: 10),
              Text(
                "Please enter the required details below to receive a password reset link. Make sure to enter the correct email and phone number associated with your account.",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Required Fields",
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.email, color: Colors.red),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email cannot be empty.";
                        }
                        if (!RegExp(r"^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                          return "Enter a valid email address.";
                        }
                        return null;
                      },
                    ),
                    // const SizedBox(height: 20),
                    //
                    // // Phone number field
                    // TextFormField(
                    //   controller: phoneController,
                    //   keyboardType: TextInputType.phone,
                    //   decoration: InputDecoration(
                    //     labelText: "Phone Number",
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //     prefixIcon: const Icon(Icons.phone, color: Colors.red),
                    //   ),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return "Phone number cannot be empty.";
                    //     }
                    //     if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) {
                    //       return "Enter a valid phone number.";
                    //     }
                    //     return null;
                    //   },
                    // ),
                    const SizedBox(height: 20),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 5,
                        ),
                        onPressed: sendResetLink,
                        child: Text(
                          "Send Password Request",
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "If you have any issues, please contact our support team at support@example.com.",
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Text(
                "Your security is our priority. Please provide accurate information to assist you better.",
                style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Back to Login",
                    style: GoogleFonts.poppins(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

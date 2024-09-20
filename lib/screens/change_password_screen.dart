// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:allinone_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Control visibility of the password
  bool _isConfirmPasswordVisible = false; // Control visibility of the confirm password
  late String _authToken;

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }




  // Show Snack Bar Message
  void _showSnackBar(BuildContext context, String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16.0)),
      backgroundColor: bgColor,
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(context, 'Please fix the errors in the form', Colors.red);
      return; // Validate the form and exit if invalid
    }

    setState(() {
      _isLoading = true;
    });

    _authToken = appStore.token; // Fetch the stored token
    const String apiUrl = 'https://ajhub.co.in/api/change-password';

    final Map<String, dynamic> payload = {
      'current_password': _currentPasswordController.text,
      'new_password': _newPasswordController.text,
      'new_password_confirmation': _confirmPasswordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_authToken", // Fix the token format with Bearer
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(context, 'Password changed successfully', Colors.green);
        Navigator.pop(context); // Navigate back after successful password change
      } else {
        // Show error from server response
        String errorMessage = 'Password change failed';
        if (response.statusCode == 400) {
          final responseBody = json.decode(response.body);
          errorMessage = responseBody['message'] ?? errorMessage;
        }
        _showSnackBar(context, errorMessage, Colors.red);
        if (kDebugMode) {
          print('Error: ${response.body}');
          print('Status Code: ${response.statusCode}');
        }
      }
    } catch (error) {
      _showSnackBar(context, 'Error: $error', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }











  Widget _buildPasswordTextField(String labelText, TextEditingController controller, {bool isConfirm = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isConfirm ? !_isConfirmPasswordVisible : !_isPasswordVisible, // Toggle visibility
      decoration: InputDecoration(
        isCollapsed: true,
        contentPadding: const EdgeInsets.all(16),
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Add border radius
          borderSide: const BorderSide(color: Colors.grey, width: 1.5), // Customize the border color and width
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2.0), // Border when focused
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5), // Border for errors
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2.0), // Focused border during error
        ),
        fillColor: Colors.white,
        filled: true, // Needed for the shadow to work

        // Add the eye icon to toggle visibility
        suffixIcon: IconButton(
          icon: Icon(
            isConfirm
                ? (_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off)
                : (_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          ),
          onPressed: () {
            setState(() {
              if (isConfirm) {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible; // Toggle for confirm password
              } else {
                _isPasswordVisible = !_isPasswordVisible; // Toggle for password
              }
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$labelText is required';
        }
        if (isConfirm && value != _newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: const Text('Change Password', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  width: 300,
                  child: Image.asset('assets/images/confitm_password.jpg'),
                ),
                _buildPasswordTextField('Current Password', _currentPasswordController),
                const SizedBox(height: 16.0),
                _buildPasswordTextField('New Password', _newPasswordController),
                const SizedBox(height: 16.0),
                _buildPasswordTextField('Confirm Password', _confirmPasswordController, isConfirm: true),
                const SizedBox(height: 20.0),
                InkWell(
                  onTap: _isLoading ? null : _changePassword,
                  child: Container(
                    height: 58,
                    width: 266,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.red,
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Reset Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


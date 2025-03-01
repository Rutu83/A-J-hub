import 'dart:convert';
import 'dart:io';
import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/screens/dashbord_screen.dart';
import 'package:ajhub_app/utils/configs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';




class ActivateMembershipPage extends StatefulWidget {
  const ActivateMembershipPage({super.key});

  @override
   ActivateMembershipPageState createState() =>  ActivateMembershipPageState();
}

class  ActivateMembershipPageState extends State<ActivateMembershipPage> {


  XFile? _selectedImage;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  final String apiUrl = "${BASE_URL}payment/approve";
  final String token = appStore.token;
  Future<void> _chooseFile() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected!")),
      );
    }
  }

  Future<void> _submitPayment() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a payment screenshot!")),
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      final request = http.MultipartRequest("POST", Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['user_id'] = '249';
      request.files.add(await http.MultipartFile.fromPath(
        'payment_screenshot',
        _selectedImage!.path,
      ));
      final response = await request.send();
      if (kDebugMode) {
        print("Response status code: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseBody);
        if (kDebugMode) {
          print("Response body: $decodedResponse");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(decodedResponse['message'] ?? "Payment submitted successfully.")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        final decodedErrorResponse = json.decode(responseBody);
        final errorMessage = decodedErrorResponse['message'] ?? "An error occurred.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );

        // Print the error response
        if (kDebugMode) {
          print("Error response: $decodedErrorResponse");
        }
      }
    } on SocketException catch (e) {
      // Handle no internet connection error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No internet connection. Please try again later.")),
      );
      if (kDebugMode) {
        print("SocketException: $e");
      }
    } on FormatException catch (e) {
      // Handle JSON format errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid response format.")),
      );
      if (kDebugMode) {
        print("FormatException: $e");
      }
    } catch (e) {
      // Handle general errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred: $e")),
      );
      if (kDebugMode) {
        print("Exception: $e");
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Activate Your Membership',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white, // Set text color to white
          ),
        ),
        backgroundColor: Colors.red, // Set AppBar background to white
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set icon color to red
        ),

      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              'Scan the QR Code to Make Your Payment',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/images/qr_code.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6.0,
                    spreadRadius: 2.0,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance, color: Colors.red, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bank Details for Payment',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, color: Colors.grey, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Account Holder: ALL IN ONE MARKETING SERVICE',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Colors.grey, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bank Name: Tamilnad Mercantile Bank Ltd.',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.credit_card, color: Colors.grey, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'Account No: 4111500508010101',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        tooltip: 'Copy Account Number',
                        icon: const Icon(Icons.copy, color: Colors.red, size: 20),
                        onPressed: () {
                          // Copy to clipboard functionality
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.grey, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'IFSC Code: TMBL0000411',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        tooltip: 'Copy IFSC Code',
                        icon: const Icon(Icons.copy, color: Colors.red, size: 20),
                        onPressed: () {
                          // Copy to clipboard functionality
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.support_agent, color: Colors.grey, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'For any queries, contact support:',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '+91 99245 73428',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),



            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [



                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.photo_camera_back, color: Colors.red, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Upload Payment Screenshot',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ensure your screenshot clearly shows the payment details.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Show the image if one is selected
                    if (_selectedImage != null)
                      Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_selectedImage!.path), // Convert XFile to File
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _chooseFile,
                      icon: const Icon(Icons.upload_file, color: Colors.white, size: 20),
                      label: Text(
                        'Choose File',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Allowed formats: JPEG, PNG, PDF. Max size: 5MB.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),





              ],
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null // Disable button while submitting
                  : () {
                _submitPayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6, // Adds a shadow effect for better visibility
              ),
              child: _isSubmitting
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white, // Match the text/icon color
                  strokeWidth: 2.5,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Submit Payment',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8.0,
                    spreadRadius: 3.0,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  const SizedBox(height: 10),
                  Text(
                    'Your payment request has been successfully submitted. Please allow up to 24 hours for admin approval. Once approved, your membership will be activated.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5, // Adds line height for better readability
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'For any questions, feel free to contact us!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}



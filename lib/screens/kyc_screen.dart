import 'dart:convert';
import 'dart:io'; // Required for File (image uploading)
import 'package:allinone_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:cached_network_image/cached_network_image.dart'; // Cached image package

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  KycScreenState createState() => KycScreenState();
}

class KycScreenState extends State<KycScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _kycData;
  File? _pickedBankProofImage; // To store the selected bank proof image
  final ImagePicker _picker = ImagePicker();

  // TextEditingControllers for editable fields
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _aadhaarCardController = TextEditingController();
  final TextEditingController _panCardController = TextEditingController();
  final TextEditingController _accountHolderNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch the KYC data when the screen is initialized
    _getKycData();
  }

  String? _bankProofImageUrl;

  // Method to handle the KYC data retrieval via GET request
  Future<void> _getKycData() async {
    const String apiUrl = "https://ajhub.co.in/api/kyc/submit"; // API URL for GET request
    final String bearerToken = appStore.token; // Bearer token for authorization

    try {
      setState(() {
        _isLoading = true; // Start loading when making the request
      });

      // Send a GET request with the Bearer token in the header
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Accept': 'application/json', // Expecting JSON response
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _kycData = responseData['kyc'];

          // Populate other controllers with data or empty string if null
          _userIdController.text = _kycData?['user_id']?.toString() ?? '';
          _aadhaarCardController.text = _kycData?['aadhaar_card']?.toString() ?? '';
          _panCardController.text = _kycData?['pan_card']?.toString() ?? '';
          _accountHolderNameController.text = _kycData?['account_holder_name'] ?? '';
          _accountNumberController.text = _kycData?['account_number']?.toString() ?? '';
          _ifscCodeController.text = _kycData?['ifsc_code'] ?? '';
          _bankNameController.text = _kycData?['bank_name'] ?? '';

          // Check if the bank_proof exists and it's a valid URL
          if (_kycData?['bank_proof'] != null) {
            _bankProofImageUrl = _kycData?['bank_proof'] as String?;
            // Ensure the URL is valid (add base URL if needed)
            if (_bankProofImageUrl != null && !_bankProofImageUrl!.startsWith("http")) {
              _bankProofImageUrl = "http://ajhub.co.in/storage/app/public/${_bankProofImageUrl!}";

              if (kDebugMode) {
                print(_bankProofImageUrl);
              }
            }
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to retrieve KYC data')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to show options for selecting image from camera or gallery
  Future<void> _pickBankProofImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, // You can change to ImageSource.camera for camera
    );

    if (pickedFile != null) {
      setState(() {
        _pickedBankProofImage = File(pickedFile.path); // Store the selected image
      });
    }
  }

  Future<void> _updateKycData() async {
    const String apiUrl = "https://ajhub.co.in/api/kyc/submit"; // API URL with user_id
    final String bearerToken = appStore.token; // Bearer token for authorization

    // Check if the bearer token is available
    if (bearerToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authorization token is missing')));
      return;
    }

    // Validate if any field is empty
    if (_aadhaarCardController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aadhaar Card is required')));
      return;
    }

    if (_panCardController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PAN Card is required')));
      return;
    }

    if (_accountHolderNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account Holder Name is required')));
      return;
    }

    if (_accountNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account Number is required')));
      return;
    }

    if (_ifscCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('IFSC Code is required')));
      return;
    }

    if (_bankNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bank Name is required')));
      return;
    }

    // Check if bank proof image is selected
    if (_pickedBankProofImage == null && (_kycData == null || _bankProofImageUrl == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bank proof image is required')));
      return;
    }

    try {
      setState(() {
        _isLoading = true; // Start loading while sending data
      });

      // Prepare multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Authorization'] = 'Bearer $bearerToken'
        ..headers['Content-Type'] = 'multipart/form-data'
        ..headers['Accept'] = 'application/json'
        ..fields['user_id'] = _userIdController.text
        ..fields['aadhaar_card'] = _aadhaarCardController.text
        ..fields['pan_card'] = _panCardController.text
        ..fields['account_holder_name'] = _accountHolderNameController.text
        ..fields['confirm_account_number'] = _accountNumberController.text
        ..fields['account_number'] = _accountNumberController.text
        ..fields['ifsc_code'] = _ifscCodeController.text
        ..fields['bank_name'] = _bankNameController.text;

      // Add bank proof image if picked
      if (_pickedBankProofImage != null) {
        request.files.add(await http.MultipartFile.fromPath('bank_proof', _pickedBankProofImage!.path));
      }

      // Send request
      final response = await request.send();

      // Get response body as string
      final responseBody = await response.stream.bytesToString();

      if (kDebugMode) {
        print('Response Body: $responseBody');
        print('Response Status Code: ${response.statusCode}');
      }

      // Handle response
      if (response.statusCode == 200) {
        if (responseBody.startsWith('{') || responseBody.startsWith('[')) {
          try {
            final responseData = json.decode(responseBody);

            // Check for the "success" key instead of "status"
            if (responseData['success'] != null && responseData['success'] == 'KYC updated successfully.') {
              setState(() {
                _kycData = responseData; // Assuming the response contains the updated KYC data
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('KYC data updated successfully')));
            } else {
              // Handle failure response from the API
              String errorMessage = responseData['message'] ?? 'Unknown error occurred';
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update KYC data: $errorMessage')));
            }
          } catch (e) {
            // Handle invalid JSON response
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Invalid response format from server')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Invalid response format from server')));
        }
      } else {
        // Handle server-side errors
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update KYC data')));
      }
    } catch (e) {
      // Catch any other errors such as network issues or timeout
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false; // Stop loading once the request is complete
      });
    }
  }




  @override
  void dispose() {

    _userIdController.dispose();
    _aadhaarCardController.dispose();
    _panCardController.dispose();
    _accountHolderNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'KYC Verification',
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
        backgroundColor: Colors.red.shade400,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,  // Set the icon color to white
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.h),
        child: Column(
          children: [


              SizedBox(height: 16.h),
              _buildTextField(_aadhaarCardController, 'Aadhaar Card'),
              SizedBox(height: 16.h),
              _buildTextField(_panCardController, 'PAN Card'),
              SizedBox(height: 16.h),
              _buildTextField(_accountHolderNameController, 'Account Holder Name'),
              SizedBox(height: 16.h),
              _buildTextField(_accountNumberController, 'Account Number'),
              SizedBox(height: 16.h),
              _buildTextField(_ifscCodeController, 'IFSC Code'),
              SizedBox(height: 16.h),
              _buildTextField(_bankNameController, 'Bank Name'),
              SizedBox(height: 16.h),
              // Bank Proof
              Text('Bank Proof:', style: TextStyle(fontSize: 16.sp)),
              SizedBox(height: 8.h),

              // Bank Proof Image or Placeholder
              Stack(
                alignment: Alignment.center,
                children: [
                  _pickedBankProofImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.0), // Set the border radius here
                    child: Image.file(
                      _pickedBankProofImage!,
                      height: 200.h,
                      width: 200.w,
                      fit: BoxFit.cover,
                    ),
                  )
                      : _kycData != null && _bankProofImageUrl != null
                      ?ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: CachedNetworkImage(
                      imageUrl: _bankProofImageUrl ?? '',
                      height: 200.0,
                      width: 200.0,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) {
                        // Print the error to the console
                        if (kDebugMode) {
                          print("Error loading image: $error");
                        }

                        // Return a placeholder image or a widget to indicate an error
                        return Image.asset('assets/images/placeholder.jpg');
                      },
                    ),
                  )

                      : ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      'assets/images/placeholder.jpg',
                      height: 200.h,
                      width: 200.w,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Add the button to update the image (both before and after picking the image)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: ElevatedButton(
                      onPressed: _pickBankProofImage,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(Colors.white), // White background
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        color: Colors.red,
                      ),
                    ),
                  ),

                  // If an image has been picked, show a button to change it
                  if (_pickedBankProofImage != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _pickedBankProofImage = null;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons.refresh_outlined,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),

            SizedBox(height: 24.h),
            Center(
              child: ElevatedButton(
                onPressed: _updateKycData,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.red.shade400),
                  padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(vertical: 16, horizontal: 32)),
                  minimumSize: WidgetStateProperty.all<Size>(const Size(500, 30)),
                ),
                child: Text(
                  _isLoading ? 'Updating KYC Data...' : 'Update KYC Data',
                  style: TextStyle(color: Colors.white, fontSize: 18.sp),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black,  // Title color (black)
          fontSize: 16.0,        // Title font size
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),  // Rounded corners
          borderSide: const BorderSide(
            color: Colors.black,  // Black border color
            width: 1.5,            // Border width
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Colors.black,  // Black border color when focused
            width: 2.0,            // Thicker border when focused
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.6),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}





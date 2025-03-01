import 'dart:convert';
import 'dart:io';
import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/utils/configs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  KycScreenState createState() => KycScreenState();
}

class KycScreenState extends State<KycScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _kycData;
  File? _pickedBankProofImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _aadhaarCardController = TextEditingController();
  final TextEditingController _panCardController = TextEditingController();
  final TextEditingController _accountHolderNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  String? _bankProofImageUrl;


  @override
  void initState() {
    super.initState();
    _getKycData();
  }



  Future<void> _getKycData() async {
    const String apiUrl = "${BASE_URL}kyc/submit";
    final String bearerToken = appStore.token;

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _kycData = responseData['kyc'];
          _userIdController.text = _kycData?['user_id']?.toString() ?? '';
          _aadhaarCardController.text = _kycData?['aadhaar_card']?.toString() ?? '';
          _panCardController.text = _kycData?['pan_card']?.toString() ?? '';
          _accountHolderNameController.text = _kycData?['account_holder_name'] ?? '';
          _accountNumberController.text = _kycData?['account_number']?.toString() ?? '';
          _ifscCodeController.text = _kycData?['ifsc_code'] ?? '';
          _bankNameController.text = _kycData?['bank_name'] ?? '';
          if (_kycData?['bank_proof'] != null) {
            _bankProofImageUrl = _kycData?['bank_proof'] as String?;
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


  Future<void> _pickBankProofImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedBankProofImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateKycData() async {
    const String apiUrl = "${BASE_URL}kyc/submit";
    final String bearerToken = appStore.token;

    if (bearerToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authorization token is missing')),
      );
      return;
    }


    if (_pickedBankProofImage == null && _bankProofImageUrl != null) {
      try {
        final response = await http.get(Uri.parse(_bankProofImageUrl!));
        if (response.statusCode == 200) {
          final tempDir = Directory.systemTemp;
          final tempFile = File('${tempDir.path}/bank_proof_temp.jpg');
          await tempFile.writeAsBytes(response.bodyBytes);
          setState(() {
            _pickedBankProofImage = tempFile;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading bank proof: $e')),
        );
        return;
      }
    }


    final bool isDataModified =
        _aadhaarCardController.text != (_kycData?['aadhaar_card'] ?? '') ||
            _panCardController.text != (_kycData?['pan_card'] ?? '') ||
            _accountHolderNameController.text != (_kycData?['account_holder_name'] ?? '') ||
            _accountNumberController.text != (_kycData?['account_number'] ?? '') ||
            _ifscCodeController.text != (_kycData?['ifsc_code'] ?? '') ||
            _bankNameController.text != (_kycData?['bank_name'] ?? '') ||
            _pickedBankProofImage != null;

    if (!isDataModified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes detected to update.')),
      );
      return;
    }


    if (_aadhaarCardController.text.isEmpty ||
        _panCardController.text.isEmpty ||
        _accountHolderNameController.text.isEmpty ||
        _accountNumberController.text.isEmpty ||
        _ifscCodeController.text.isEmpty ||
        _bankNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Authorization'] = 'Bearer $bearerToken'
        ..headers['Accept'] = 'application/json'
        ..fields['user_id'] = _userIdController.text
        ..fields['aadhaar_card'] = _aadhaarCardController.text
        ..fields['pan_card'] = _panCardController.text
        ..fields['account_holder_name'] = _accountHolderNameController.text
        ..fields['account_number'] = _accountNumberController.text
        ..fields['confirm_account_number'] = _accountNumberController.text
        ..fields['ifsc_code'] = _ifscCodeController.text
        ..fields['bank_name'] = _bankNameController.text;

      if (_pickedBankProofImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'bank_proof',
            _pickedBankProofImage!.path,
          ),
        );
      }
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (kDebugMode) {
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: $responseBody');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);

        if (responseData['success'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['success'])),
          );
          setState(() {
            _kycData = responseData['kyc'] ?? {};
          });
        } else {
          final errorMessage = responseData['message'] ?? 'Unexpected error occurred';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $errorMessage')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
          color: Colors.white,
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
              Text('Bank Proof:', style: TextStyle(fontSize: 16.sp)),
              SizedBox(height: 8.h),
              Stack(
                alignment: Alignment.center,
                children: [
                  _pickedBankProofImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
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
                        if (kDebugMode) {
                          print("Error loading image: $error");
                        }
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: ElevatedButton(
                      onPressed: _pickBankProofImage,
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
                        Icons.add_a_photo_outlined,
                        color: Colors.red,
                      ),
                    ),
                  ),

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

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 2.0,
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





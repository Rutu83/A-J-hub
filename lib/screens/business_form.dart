// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/screens/dashbord_screen.dart';
import 'package:ajhub_app/utils/configs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessForm extends StatefulWidget {
  const BusinessForm({super.key});

  @override
  State<BusinessForm> createState() => _BusinessFormState();
}

class _BusinessFormState extends State<BusinessForm> {
  File? _businessLogo;
  File? _personalPhoto;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source, {required bool isLogo}) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          if (isLogo) {
            _businessLogo = File(pickedFile.path);
          } else {
            _personalPhoto = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context,
      {required bool isLogo}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.w),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isLogo: isLogo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isLogo: isLogo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitBusinessProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_businessLogo == null) {
      _showSnackbar('Please provide a logo for your business.', Colors.red);
      return;
    }
    if (_personalPhoto == null) {
      _showSnackbar('Please provide a personal photo.', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final bool wasAnyBusinessActive =
        prefs.getInt('selected_business_id') != null;

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${BASE_URL}businessprofile'));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${appStore.token}',
      });

      print('hello return error  : ${request}');

      request.fields['business_name'] = _businessNameController.text;
      request.fields['owner_name'] = _ownerNameController.text;
      request.fields['mobile_number'] = _mobileNumberController.text;
      request.fields['email'] = _emailController.text;
      request.fields['website'] = _websiteController.text;
      request.fields['address'] = _addressController.text;

      final logoMimeType = lookupMimeType(_businessLogo!.path);
      request.files.add(await http.MultipartFile.fromPath(
        'logo',
        _businessLogo!.path,
        contentType:
            logoMimeType != null ? MediaType.parse(logoMimeType) : null,
      ));

      const String correctPersonalPhotoKey = 'personal_photo';
      final photoMimeType = lookupMimeType(_personalPhoto!.path);
      request.files.add(await http.MultipartFile.fromPath(
        correctPersonalPhotoKey,
        _personalPhoto!.path,
        contentType:
            photoMimeType != null ? MediaType.parse(photoMimeType) : null,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackbar('Business profile submitted successfully!', Colors.green);

        final responseData = json.decode(response.body);
        final newBusiness = responseData['data'];

        if (!wasAnyBusinessActive && newBusiness != null) {
          await _storeActiveBusiness(newBusiness);
          if (kDebugMode) {
            print(
                'First business created. Set as active: ${json.encode(newBusiness)}');
          }
        }

        // --- UPDATED: Compulsory redirect to the BusinessList page ---
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const DashboardScreen()), // <-- Make sure this is your main screen
          (Route<dynamic> route) =>
              false, // This predicate removes all previous routes
        );
        // -------------------------------------------------------------
      } else {
        final errorMessage = json.decode(response.body)['message'] ??
            'An unknown error occurred.';
        _showSnackbar(
            'Error ${response.statusCode}: $errorMessage', Colors.red);
      }
    } catch (e) {
      _showSnackbar('An unexpected error occurred: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _storeActiveBusiness(dynamic business) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (business == null || business['id'] == null) return;

    await prefs.setInt('selected_business_id', business['id']);
    await prefs.setString(
        'active_business_name', business['business_name'] ?? 'No Name');
    await prefs.setString('active_business_logo', business['logo'] ?? '');
    await prefs.setString(
        'active_business_owner_photo', business['personal_photo'] ?? '');
    await prefs.setString('active_business', json.encode(business));
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: color,
        content: Row(
          children: [
            Icon(color == Colors.red ? Icons.error : Icons.check_circle,
                color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style:
                    GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _businessLogo = null;
      _personalPhoto = null;
      _businessNameController.clear();
      _ownerNameController.clear();
      _mobileNumberController.clear();
      _emailController.clear();
      _websiteController.clear();
      _addressController.clear();
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Add Business'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            16.w, 6.h, 16.w, 100.h), // Add bottom padding for buttons
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        buildLabel('Business Logo', isRequired: true),
                        SizedBox(height: 8.h),
                        _buildImageUploader(
                          imageFile: _businessLogo,
                          onTap: () => _showImageSourceActionSheet(context,
                              isLogo: true),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      children: [
                        buildLabel('Personal Photo', isRequired: true),
                        SizedBox(height: 8.h),
                        _buildImageUploader(
                          imageFile: _personalPhoto,
                          onTap: () => _showImageSourceActionSheet(context,
                              isLogo: false),
                          isPersonal: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              buildLabel('Business Name', isRequired: true),
              _buildTextFormField(
                controller: _businessNameController,
                hintText: 'Enter your business name',
                icon: Icons.business,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your business name'
                    : null,
              ),
              SizedBox(height: 16.h),
              buildLabel('Owner Name', isRequired: true),
              _buildTextFormField(
                controller: _ownerNameController,
                hintText: 'Enter owner name',
                icon: Icons.person,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your owner name'
                    : null,
              ),
              SizedBox(height: 16.h),
              buildLabel('Mobile Number', isRequired: true),
              _buildTextFormField(
                controller: _mobileNumberController,
                hintText: 'Enter mobile number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter your mobile number';
                  if (value.length != 10)
                    return 'Please enter a valid 10-digit mobile number';
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              buildLabel('Email Id', isRequired: true),
              _buildTextFormField(
                controller: _emailController,
                hintText: 'Enter email ID',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter your email ID';
                  final emailRegex = RegExp(
                      r"^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
                  if (!emailRegex.hasMatch(value))
                    return 'Please enter a valid email ID';
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              buildLabel('Website Name'),
              _buildTextFormField(
                controller: _websiteController,
                hintText: 'Enter website name',
                icon: Icons.web,
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 16.h),
              buildLabel('Address', isRequired: true),
              _buildTextFormField(
                controller: _addressController,
                hintText: 'Enter address',
                icon: Icons.location_on,
                maxLines: 3,
                minLines: 1,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your Address'
                    : null,
              ),
            ],
          ),
        ),
      ),
      bottomSheet: buildBottomButtons(),
    );
  }

  Widget _buildImageUploader({
    required File? imageFile,
    required VoidCallback onTap,
    bool isPersonal = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120.w,
        height: 120.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.shade300),
          borderRadius: BorderRadius.circular(10.r),
          color: Colors.grey[200],
          image: imageFile != null
              ? DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover)
              : null,
        ),
        child: imageFile == null
            ? Center(
                child: Icon(
                  isPersonal
                      ? Icons.person_add_alt_1_outlined
                      : Icons.add_a_photo_outlined,
                  size: 30,
                  color: Colors.grey,
                ),
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.red, size: 20),
                ),
              ),
      ),
    );
  }

  Widget buildBottomButtons() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SizedBox(
              height: 50.h,
              child: OutlinedButton(
                onPressed: !_isLoading ? _clearForm : null,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('Clear',
                    style: TextStyle(color: Colors.red, fontSize: 16.sp)),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: SizedBox(
              height: 50.h,
              child: ElevatedButton(
                onPressed: !_isLoading ? _submitBusinessProfile : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text('Submit',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int minLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.red),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                width: 1,
                height: 24.h,
                color: Colors.grey.shade300,
              ),
            ],
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget buildLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RichText(
        text: TextSpan(
          text: label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          children: isRequired
              ? [
                  const TextSpan(
                      text: ' *',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold))
                ]
              : [],
        ),
      ),
    );
  }
}

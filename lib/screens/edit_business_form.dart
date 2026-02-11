// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/utils/configs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditBusinessForm extends StatefulWidget {
  final dynamic business;

  const EditBusinessForm({super.key, required this.business});

  @override
  State<EditBusinessForm> createState() => _EditBusinessFormState();
}

class _EditBusinessFormState extends State<EditBusinessForm> {
  // --- MODIFIED: Renamed for clarity and added personal photo variables ---
  File? _businessLogoFile;
  String? _businessLogoUrl;
  File? _personalPhotoFile;
  String? _personalPhotoUrl;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _businessNameController.text = widget.business['business_name'] ?? '';
    _ownerNameController.text = widget.business['owner_name'] ?? '';
    _mobileNumberController.text = widget.business['mobile_number'] ?? '';
    _emailController.text = widget.business['email'] ?? '';
    _websiteController.text = widget.business['website'] ?? '';
    _addressController.text = widget.business['address'] ?? '';

    // Populate business logo URL
    if (widget.business['logo'] != null &&
        widget.business['logo'].startsWith('http')) {
      _businessLogoUrl = widget.business['logo'];
    }

    // --- NEW: Populate personal photo URL ---
    if (widget.business['personal_photo'] != null &&
        widget.business['personal_photo'].startsWith('http')) {
      _personalPhotoUrl = widget.business['personal_photo'];
    }
  }

  // --- MODIFIED: To handle both logo and personal photo ---
  Future<void> _pickImage(ImageSource source, {required bool isLogo}) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          if (isLogo) {
            _businessLogoFile = File(pickedFile.path);
            _businessLogoUrl = null; // Clear URL if a new file is picked
          } else {
            _personalPhotoFile = File(pickedFile.path);
            _personalPhotoUrl = null; // Clear URL
          }
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error picking image: $e');
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

  Future<void> _updateBusinessProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final String token = appStore.token;
    final String apiUrl =
        '${BASE_URL}update/businessprofile/${widget.business['id']}';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Add text fields
      request.fields['business_name'] = _businessNameController.text;
      request.fields['owner_name'] = _ownerNameController.text;
      request.fields['mobile_number'] = _mobileNumberController.text;
      request.fields['email'] = _emailController.text;
      request.fields['website'] = _websiteController.text;
      request.fields['address'] = _addressController.text;

      // Add business logo file if it was changed
      if (_businessLogoFile != null) {
        request.files.add(
            await http.MultipartFile.fromPath('logo', _businessLogoFile!.path));
      }

      // --- NEW: Add personal photo file if it was changed ---
      if (_personalPhotoFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'personal_photo', _personalPhotoFile!.path));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        debugPrint('Profile updated successfully: $responseBody');
        final responseData = json.decode(responseBody);
        debugPrint('Profile updated successfully: $responseBody');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? activeBusinessId = prefs.getInt('selected_business_id');
        if (activeBusinessId != null &&
            activeBusinessId == widget.business['id']) {
          // If it IS the active business, update the 'active_business' data in SharedPreferences
          // with the new data we just received from the server.
          // The API response should ideally return the full updated business object.
          // Assuming 'data' contains the updated business profile.
          if (responseData['data'] != null) {
            await prefs.setString(
                'active_business', json.encode(responseData['data']));
            debugPrint(
                "Active business data in SharedPreferences has been updated.");
          }
        }
        _showSuccessMessage('Profile updated successfully!');
        Navigator.pop(context, true);
      } else {
        final errorBody = await response.stream.bytesToString();
        debugPrint('Error Response Body: $errorBody');
        _showErrorMessage('Failed to update profile. Please try again.');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _showErrorMessage('An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Update Business Detail'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 80.h, top: 6),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- NEW: Row to hold both image uploaders ---
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
                          imageFile: _businessLogoFile,
                          imageUrl: _businessLogoUrl,
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
                          imageFile: _personalPhotoFile,
                          imageUrl: _personalPhotoUrl,
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

              buildLabel('Email', isRequired: true),
              _buildTextFormField(
                controller: _emailController,
                hintText: 'Enter email',
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

              buildLabel('Website Name', isRequired: false),
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
              SizedBox(height: 16.h),

              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW: Reusable widget for image uploading box ---
  Widget _buildImageUploader({
    File? imageFile,
    String? imageUrl,
    required VoidCallback onTap,
    bool isPersonal = false,
  }) {
    ImageProvider? imageProvider;
    if (imageFile != null) {
      imageProvider = FileImage(imageFile);
    } else if (imageUrl != null) {
      imageProvider = NetworkImage(imageUrl);
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120.w,
        height: 120.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.shade300),
          borderRadius: BorderRadius.circular(10.r),
          color: Colors.grey[200],
          image: imageProvider != null
              ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
              : null,
        ),
        child: imageProvider == null
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

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateBusinessProfile,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text('Update',
                style: TextStyle(fontSize: 16.sp, color: Colors.white)),
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
      ),
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget buildLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: label,
          style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black),
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

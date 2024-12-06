// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/screens/business_list.dart';
import 'package:allinone_app/screens/category_selection_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class BusinessForm extends StatefulWidget {
  const BusinessForm({super.key});

  @override
  State<BusinessForm> createState() => _BusinessFormState();
}

class _BusinessFormState extends State<BusinessForm> {
  File? _image;  // Variable to store the image
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? selectedState;
  List<dynamic> states = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedCategoryImage; // For storing the category image URL
  String? _selectedCategoryName;  // For storing the category name
  String? _selectedCategoryId;    // For storing the category ID
  bool _isLoading = false;  // To manage loading state

  Future<void> fetchStates() async {
    try {
      final response = await http.get(Uri.parse('https://ajhub.co.in/get-states-regby-country/1'));
      if (response.statusCode == 200) {
        setState(() {
          states = json.decode(response.body);
          selectedState = null;
        });
      } else {
        if (kDebugMode) {
          print(response.statusCode);
        }
        if (kDebugMode) {
          print(response.body);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }


  String? _selectedCategory;  // Variable to store selected business category

  // Method to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image from gallery: $e');
      }
    }
  }

  // Method to pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image from camera: $e');
      }
    }
  }

  // Show bottom sheet with camera and gallery options
  void _showImageSourceActionSheet(BuildContext context) {
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
                  Navigator.pop(context);  // Close the bottom sheet
                  _pickImageFromGallery();  // Open gallery
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);  // Close the bottom sheet
                  _pickImageFromCamera();  // Open camera
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitBusinessProfile() async {
    if (_formKey.currentState?.validate() == true) {
      setState(() {
        _isLoading = true; // Start loading indicator
      });

      try {
        // Create a multipart request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://ajhub.co.in/api/businessprofile'),
        );

        // Add headers including the token
        request.headers.addAll({
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer ${appStore.token}', // Add your token here
        });

        // Add fields
        request.fields['business_name'] = _businessNameController.text;
        request.fields['owner_name'] = _ownerNameController.text.isNotEmpty
            ? _ownerNameController.text
            : 'Owner Name'; // Optional
        request.fields['mobile_number'] = _mobileNumberController.text;
        request.fields['email'] = _emailController.text.isNotEmpty
            ? _emailController.text
            : ''; // Optional
        request.fields['website'] = _websiteController.text.isNotEmpty
            ? _websiteController.text
            : ''; // Optional
        request.fields['address'] = _addressController.text;
        request.fields['category_id'] = _selectedCategoryId!;
        request.fields['state_id'] = selectedState ?? '';

        // Add logo as a file
        if (_image != null) {
          var logoFile = await http.MultipartFile.fromPath(
            'logo',
            _image!.path, // The file path of the image
            contentType: MediaType('image', 'jpeg'), // Adjust content type if necessary (e.g., png, jpg)
          );
          request.files.add(logoFile);
        }

        // Debugging the fields and files
        debugPrint("Request Fields: ${request.fields}");
        debugPrint("Request Files: ${request.files.length}");

        // Send request
        var response = await request.send();

        // Handle response
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Successfully submitted
          debugPrint('Business profile submitted successfully!');
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BusinessList()),
          );
        } else {
          // Handle server errors
          final errorMessage = await response.stream.bytesToString();

          // Parse the error message if it's in JSON format
          try {
            var errorJson = json.decode(errorMessage);
            String error = errorJson['error'] ?? 'Unknown error';
            debugPrint('Failed: ${response.statusCode}');
            debugPrint('Response Body: $error');

            // Display the error message using the dialog
            _showErrorDialog('Error: ${response.statusCode}', error);
          } catch (e) {
            // If there's an issue with JSON parsing, log the raw message
            debugPrint('Failed to parse error message: $errorMessage');
            _showErrorDialog('Error', 'An unexpected error occurred: $errorMessage');
          }

          setState(() {
            _isLoading = false;
          });
        }
      } catch (e, stackTrace) {
        // Catch any exceptions that happen during the process
        debugPrint('Error: $e');
        debugPrintStack(stackTrace: stackTrace);

        // Show a generic error message
        _showErrorDialog('Error', 'An unexpected error occurred. Please try again.');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }




// Show error message in a dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  // Navigate to the category selection screen
  void _navigateToCategorySelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectionScreen(
          onCategorySelected: (String categoryId, String categoryName) {
            // This can be used for immediate updates, if needed
          },
        ),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        _selectedCategoryId = result['id'];
        _selectedCategoryName = result['name'];
        _selectedCategoryImage = result['image'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStates();
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
      body:   SingleChildScrollView(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 0.h, top: 6),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel('Select Your Business Logo'),
              InkWell(
                onTap: () {
                  _showImageSourceActionSheet(context);
                },
                child: SizedBox(
                  width: 110.w,
                  height: 100.h,
                  child: Stack(
                    children: [
                      Container(
                        width: 110.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(10.r),
                          color: Colors.grey[200],
                          image: _image != null
                              ? DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: _image == null
                            ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        )
                            : null,
                      ),
                      if (_image != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () {
                              _showImageSourceActionSheet(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                              child: const Icon(
                                Icons.add_a_photo,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              buildLabel('Business Category (Optional)'),
              InkWell(
                onTap: _navigateToCategorySelection,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade600),
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 35.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              image: DecorationImage(
                                image: _selectedCategoryImage != null
                                    ? NetworkImage(_selectedCategoryImage!)
                                    : const AssetImage('assets/images/placeholder.jpg') as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            _selectedCategoryName ?? 'Select Category',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Image.asset(
                        'assets/icons/edit.png',
                        width: 20.w,
                        height: 20.h,
                      ),
                    ],
                  ),
                ),
              ),



              SizedBox(height: 16.h),
              buildLabel('Business Name', isRequired: true),
              _buildTextFormField(
                controller: _businessNameController,
                hintText: 'Enter your business name',
                icon: Icons.business,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your business name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),
              buildLabel('Owner Name', isRequired: true),
              _buildTextFormField(
                controller: _ownerNameController,
                hintText: 'Enter owner name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your owner name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),
              buildLabel('Mobile Number', isRequired: true),
              _buildTextFormField(
                controller: _mobileNumberController,
                hintText: 'Enter mobile number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  if (value.length != 10) {
                    return 'Please enter a valid 10-digit mobile number';
                  }
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
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r"^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email ID';  // Return error message if invalid
                    }
                    return null;  // Return null if email is valid
                  }
                  return 'Please enter your email ID';  // Return a message if the field is empty
                },
              ),


              SizedBox(height: 16.h),
              buildLabel('Website Name', isRequired: true),
              _buildTextFormField(
                controller: _websiteController,
                hintText: 'Enter website name',
                icon: Icons.web,
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your website name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),
              buildLabel('Address', isRequired: true),
              _buildTextFormField(
                controller: _addressController,
                hintText: 'Enter address',
                icon: Icons.location_on,
                maxLines: 3,  // Max 3 lines
                minLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Address';
                  }
                  return null;
                },
                // Start with 1 line
              ),

              SizedBox(height: 16.h),
              buildLabel('State', isRequired: true),
              _buildStateDropdown(),

              SizedBox(height: 16.h),
              buildBottomButtons(),
            ],
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
          // Clear Button
          Expanded(
            child: SizedBox(
              height: 50.h, // Ensure both buttons have the same height
              child: OutlinedButton(
                onPressed: !_isLoading ? _clearForm : null, // Disable when loading
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w), // Space between buttons

          // Submit Button
          Expanded(
            child: SizedBox(
              height: 50.h, // Ensure both buttons have the same height
              child: ElevatedButton(
                onPressed: !_isLoading ? _submitBusinessProfile : null, // Disable when loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Button background color
                ),
                child: _isLoading
                    ? SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: const CircularProgressIndicator(
                    color: Colors.red, // Circular progress indicator color
                    strokeWidth: 2.5, // Adjust stroke width
                  ),
                )
                    : Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                ),
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
    int minLines = 1, // Add minLines for the initial line count
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      keyboardType: keyboardType,
      minLines: minLines,  // Show one line initially
      maxLines: maxLines,  // Expand up to 3 lines when needed
      validator: validator,
    );
  }

  void _clearForm() {
    setState(() {
      _image = null;
      _selectedCategory = null;
      selectedState = null;
      _formKey.currentState?.reset();  // Reset form fields
    });
  }

  Widget _buildStateDropdown() {
    return InkWell(
      onTap: () {
        _showStateSelectionSheet();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.location_city, color: Colors.red),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  width: 1,
                  height: 24.h,
                  color: Colors.grey.shade300,
                ),
                SizedBox(width: 10.w),
                Text(
                  selectedState != null
                      ? states.firstWhere((state) => state['id'].toString() == selectedState)['name']
                      : 'Select Your State',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: selectedState != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
            Image.asset(
              'assets/icons/edit.png',
              width: 20.w,
              height: 20.h,
            ),
          ],
        ),
      ),
    );
  }

  void _showStateSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 700,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Select Your State',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: states.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(states[index]['name']),
                          onTap: () {
                            setState(() {
                              selectedState = states[index]['id'].toString();
                            });
                            Navigator.pop(context);
                          },
                        ),
                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildLabel(String label, {bool isRequired = false}) {
    return RichText(
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
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]
            : [],
      ),
    );
  }
}

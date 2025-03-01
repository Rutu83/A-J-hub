// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/screens/category_selection_screen.dart';
import 'package:ajhub_app/utils/configs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditBusinessForm extends StatefulWidget {
  final dynamic business; // Added to hold business data

  const EditBusinessForm({super.key, required this.business});

  @override
  State<EditBusinessForm> createState() => _EditBusinessFormState();
}

class _EditBusinessFormState extends State<EditBusinessForm> {
  File? _image;  // Variable to store the image
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false; // Tracks if the form is being submitted

  String? selectedState;
  List<dynamic> states = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  ImageProvider _getCategoryImage(String category) {
    switch (category) {
      case 'Retail':
        return const AssetImage('assets/icons/retail.png');
      case 'Food & Beverage':
        return const AssetImage('assets/icons/restaurant.png');
      case 'Technology':
        return const AssetImage('assets/icons/project-management.png');
      case 'Healthcare':
        return const AssetImage('assets/icons/healthcare.png');
      case 'Education':
        return const AssetImage('assets/icons/school.png');
      case 'Real Estate':
        return const AssetImage('assets/icons/house.png');
      default:
        return const AssetImage('assets/images/placeholder.jpg');
    }
  }

  String? _selectedCategory;  // Variable to store selected business category
  bool _validateImageFormat(String path) {
    final validExtensions = ['jpg', 'jpeg', 'png'];
    final extension = path.split('.').last.toLowerCase();
    return validExtensions.contains(extension);


  }

  // Method to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (_validateImageFormat(pickedFile.path)) {
          setState(() {
            _image = File(pickedFile.path);
          });
        } else {
          _showErrorMessage('Invalid file format. Please select a JPEG, PNG, or JPG image.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image from gallery: $e');
      }
    }
  }
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        if (_validateImageFormat(pickedFile.path)) {
          setState(() {
            _image = File(pickedFile.path);
          });
        } else {
          _showErrorMessage('Invalid file format. Please select a JPEG, PNG, or JPG image.');
        }
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










  String? _selectedCategoryId;  // Store the selected category ID

  void _navigateToCategorySelection() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectionScreen(
          onCategorySelected: (String categoryId, String categoryName) {
            setState(() {
              _selectedCategoryId = categoryId;
              _selectedCategory = categoryName;
            });
          },
        ),
      ),
    );
  }


  String? _imageUrl; // For remote URL

  @override
  void initState() {
    super.initState();
    fetchStates();

    // Initialize the text controllers with business data
    _businessNameController.text = widget.business['business_name'] ?? '';
    _ownerNameController.text = widget.business['owner_name'] ?? '';
    _mobileNumberController.text = widget.business['mobile_number'] ?? '';
    _emailController.text = widget.business['email'] ?? '';
    _websiteController.text = widget.business['website'] ?? '';
    _addressController.text = widget.business['address'] ?? '';

    _selectedCategory = widget.business['category_name'];
    _selectedCategoryId = widget.business['category_id'].toString();

    // Determine if the logo is a file or a URL
    if (widget.business['logo'] != null && widget.business['logo'].startsWith('http')) {
      _imageUrl = widget.business['logo']; // Remote URL
    } else if (widget.business['logo'] != null) {
      _image = File(widget.business['logo']); // Local file path
    }
  }




  Future<void> _updateBusinessProfile() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final String token = appStore.token;
    final String apiUrl = '${BASE_URL}update/businessprofile/${widget.business['id']}';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add text fields
      request.fields['business_name'] = _businessNameController.text;
      request.fields['owner_name'] = _ownerNameController.text;
      request.fields['mobile_number'] = _mobileNumberController.text;
      request.fields['email'] = _emailController.text;
      request.fields['website'] = _websiteController.text;
      request.fields['address'] = _addressController.text;
      if (selectedState != null) request.fields['state_id'] = selectedState!;
      if (_selectedCategoryId != null) request.fields['category_id'] = _selectedCategoryId!;

      // Add image file if available
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath('logo', _image!.path));
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        debugPrint('Profile updated successfully: $responseBody');

        // Notify the previous page about the success
        Navigator.pop(context, true); // Return `true` to indicate success
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
        _isLoading = false; // Stop loading
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Update Business Detail'),
      ),
      body: Stack(  // Using Stack to position the bottom sheet
        children: [
          // Main Content: Form fields
          SingleChildScrollView(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 80.h, top: 6),
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
                              image: _image != null || _imageUrl != null // Check if there's an image or URL
                                  ? DecorationImage(
                                image: _image != null
                                    ? FileImage(_image!) // Local file
                                    : NetworkImage(_imageUrl!) as ImageProvider, // Remote URL
                                fit: BoxFit.cover,
                              )
                                  : null, // No image
                            ),
                            child: _image == null && _imageUrl == null
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
                          if (_image != null || _imageUrl != null) // Display edit button only if there's an image
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
                    onTap: () {
                      _navigateToCategorySelection();
                    },
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
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    image: _selectedCategory != null
                                        ? _getCategoryImage(_selectedCategory!)
                                        : const AssetImage('assets/images/c5.png') as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                _selectedCategory ?? 'Select Category',
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
                  buildLabel('Email', isRequired: true),
                  _buildTextFormField(
                    controller: _emailController,
                    hintText: 'Enter email',
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
                    maxLines: 3,  // Max 3 lines
                    minLines: 1,  // Start with 1 line
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Address';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),
                  buildLabel('State', isRequired: true),
                  _buildStateDropdown(),
                ],
              ),
            ),
          ),

          // Fixed Bottom Sheet with Clear and Submit Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset:  const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50.h, // Ensure both buttons have the same height
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateBusinessProfile, // Disable button if loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Button background color
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white, // Spinner color
                            strokeWidth: 2, // Thickness of the spinner
                          ),
                        )
                            : Text(
                          'Update',
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


  // void _clearForm() {
  //   setState(() {
  //     _image = null;
  //     _selectedCategory = null;
  //     selectedState = null;
  //     _formKey.currentState?.reset();  // Reset form fields
  //   });
  // }

  Widget _buildStateDropdown() {
    return InkWell(
      onTap: () {
        _showStateSelectionSheet();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
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

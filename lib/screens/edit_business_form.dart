// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/screens/category_selection_screen.dart';
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
  final List<String> _businessCategories = [
    'Retail',
    'Food & Beverage',
    'Technology',
    'Healthcare',
    'Education',
    'Real Estate',
  ];
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

    print(_selectedCategory);
  }




  Future<void> _updateBusinessProfile() async {
    final String token = appStore.token; // Retrieve your token from appStore
    final String apiUrl = 'https://ajhub.co.in/api/update/businessprofile/${widget.business['id']}'; // Assuming 'id' is the business ID

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'business_name': _businessNameController.text,
          'owner_name': _ownerNameController.text,
          'mobile_number': _mobileNumberController.text,
          'email': _emailController.text,
          'website': _websiteController.text,
          'address': _addressController.text,
          'state_id': selectedState,
          'category_id': _selectedCategoryId,
          // Include additional fields as necessary
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Profile updated successfully: ${response.body}');
        }
        // Pass true as the result to indicate success
        Navigator.pop(context, true);
      } else {
        if (kDebugMode) {
          print('Failed to update profile: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Add Business Detail'),
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
                  buildLabel('Owner Name'),
                  _buildTextFormField(
                    controller: _ownerNameController,
                    hintText: 'Enter owner name',
                    icon: Icons.person,
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
                  buildLabel('Email Id'),
                  _buildTextFormField(
                    controller: _emailController,
                    hintText: 'Enter email ID',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final emailRegex = RegExp(r"^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email ID';
                        }
                      }
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
                  buildLabel('Address'),
                  _buildTextFormField(
                    controller: _addressController,
                    hintText: 'Enter address',
                    icon: Icons.location_on,
                    maxLines: 3,  // Max 3 lines
                    minLines: 1,  // Start with 1 line
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
                        onPressed: _updateBusinessProfile, // Define this function to handle form submission
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Button background color
                        ),
                        child: Text(
                          'Edit',
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

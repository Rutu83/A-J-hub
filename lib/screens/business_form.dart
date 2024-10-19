// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:allinone_app/screens/business_list.dart';
import 'package:allinone_app/screens/category_selection_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Navigate to the category selection screen
  void _navigateToCategorySelection() async {
  await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => CategorySelectionScreen(
            categories: _businessCategories,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          )
      ),
    );
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
                    hintText: 'Enter owner name',
                    icon: Icons.person,
                  ),

                  SizedBox(height: 16.h),
                  buildLabel('Mobile Number', isRequired: true),
                  _buildTextFormField(
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
                    hintText: 'Enter website name',
                    icon: Icons.web,
                    keyboardType: TextInputType.url,
                  ),

                  SizedBox(height: 16.h),
                  buildLabel('Address'),
                  _buildTextFormField(
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
                        onPressed: _clearForm, // Define this function to clear the form fields
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
                        onPressed: _submitForm, // Define this function to handle form submission
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Button background color
                        ),
                        child: Text(
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
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int minLines = 1, // Add minLines for the initial line count
    String? Function(String?)? validator,
  }) {
    return TextFormField(
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

  void _submitForm() {
    if (_formKey.currentState?.validate() == true) {
      // Process form data and navigate to the BusinessList screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BusinessList(
            businessName: 'tgggt',  // Replace with actual field value
            ownerName: 'Owner Name',  // Replace with actual field value
            mobileNumber: '8796586795',  // Replace with actual field value
            email: 'Email ID',  // Replace with actual field value
            website: 'Website',  // Replace with actual field value, optional
            address: 'Address',  // Replace with actual field value
            selectedCategory: _selectedCategory ?? 'No Category',  // Use selected category
            state: selectedState != null ? states.firstWhere((state) => state['id'].toString() == selectedState)['name'] : 'State',  // Get selected state
            logo: _image,  // Pass the selected image
          ),
        ),
      );
    } else {
      // Show validation error
      if (kDebugMode) {
        print('Form is invalid');
      }
    }
  }



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
                const Icon(Icons.location_city, color: Colors.red),  // Icon instead of image
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w,vertical: 7),
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
      backgroundColor: Colors.white, // Set background color to white
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      isScrollControlled: true, // Allow full height for the bottom sheet
      builder: (BuildContext context) {
        return Container(
          height: 700,
          padding: EdgeInsets.all(16.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(),

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
                            Navigator.pop(context);  // Close the bottom sheet after selection
                          },
                        ),
                        Divider( // Horizontal line after each state
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

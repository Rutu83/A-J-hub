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
import 'package:shared_preferences/shared_preferences.dart';

class CategoryEditBusinessForm extends StatefulWidget {
  const CategoryEditBusinessForm({super.key});

  @override
  State<CategoryEditBusinessForm> createState() => _CategoryEditBusinessFormState();
}

class _CategoryEditBusinessFormState extends State<CategoryEditBusinessForm> {
  File? _image; // Variable to store the image
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
  String? _selectedCategory; // Variable to store selected business category

  @override
  void initState() {
    super.initState();
    fetchStates();
    fetchBusinessData(); // Fetch the business data based on stored ID
  }

  // Fetch States
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
          print(response.body);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }



  // Fetch stored business ID
  Future<int?> getStoredBusinessID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selected_business_id');
  }

  Future<void> fetchBusinessData() async {
    int? businessID = await getStoredBusinessID();
    String? token = appStore.token; // Fetch token

    final String apiUrl = 'https://ajhub.co.in/api/getbusinessprofile/$businessID';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<dynamic> businesses = responseData['data'];

        if (businesses.isNotEmpty) {
          // Here, I'm using the first business from the list. You can modify to select a specific one.
          final businessData = businesses[0];

          setState(() {
            _businessNameController.text = businessData['business_name'];
            _ownerNameController.text = businessData['owner_name'];
            _mobileNumberController.text = businessData['mobile_number'];
            _emailController.text = businessData['email'];
            _websiteController.text = businessData['website'];
            _addressController.text = businessData['address'];
            selectedState = businessData['state']['id'].toString(); // Fetch state name if needed
            _selectedCategory = businessData['category']['name']; // Set the category name
          });
        } else {
          if (kDebugMode) {
            print('No businesses found');
          }
        }
      } else {
        if (kDebugMode) {
          print('Failed to fetch business data: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching business data: $e');
      }
    }
    }


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
                  Navigator.pop(context); // Close the bottom sheet
                  _pickImageFromGallery(); // Open gallery
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _pickImageFromCamera(); // Open camera
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
        ),
      ),
    );
  }

  // Get category image based on the selected category
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Business Detail'),
      ),
      body: Stack(
        children: [
          // Main Content: Form fields
          SingleChildScrollView(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 80.h, top: 6),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLabel('Business Logo'),
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
                  ),
                  SizedBox(height: 16.h),
                  buildLabel('Email Id'),
                  _buildTextFormField(
                    controller: _emailController,
                    hintText: 'Enter email ID',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
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
                    maxLines: 3,
                    minLines: 1,
                  ),
                  SizedBox(height: 16.h),
                  buildLabel('State', isRequired: true),
                  _buildStateDropdown(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build a text form field
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int minLines = 1,
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
      minLines: minLines,
      maxLines: maxLines,
    );
  }

  // Build state dropdown
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

// Show state selection sheet
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

// Build a label with optional required indicator
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


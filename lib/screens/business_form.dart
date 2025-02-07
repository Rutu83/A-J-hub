import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/screens/category_selection_screen.dart';
import 'package:allinone_app/utils/configs.dart';
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
  File? _image;
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
  String? _selectedCategoryImage;
  String? _selectedCategoryName;
  String? _selectedCategoryId;
  bool _isLoading = false;

  Future<void> fetchStates() async {
    try {
      final response = await http.get(Uri.parse('https://ajhub.co.in/get-states-regby-country/1'));
      if (response.statusCode == 200) {
        setState(() {
          states = json.decode(response.body);
          selectedState = null;
        });
      } else {}
    } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    }
  }



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
      print(e);
    }}
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }

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
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
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
        _isLoading = true;
      });


      if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
        _showSnackbar('Please select a category.', Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (selectedState == null || selectedState!.isEmpty) {
        _showSnackbar('Please select a state.', Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (_websiteController.text.isNotEmpty &&
          !RegExp(r"^(https?://)?([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)?$")
              .hasMatch(_websiteController.text)) {
        _showSnackbar('Please enter a valid website URL.', Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        if (_image != null) {
          int fileSize = await _image!.length();
          if (fileSize > 2048 * 1024) {
            _showSnackbar('The logo image must not exceed 2 MB.', Colors.red);
            setState(() {
              _isLoading = false;
            });
            return;
          }
        } else {
          _showSnackbar('Please provide a logo for your business.', Colors.red);
          setState(() {
            _isLoading = false;
          });
          return;
        }

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${BASE_URL}businessprofile'),
        );
        request.headers.addAll({
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer ${appStore.token}',
        });

        request.fields['business_name'] = _businessNameController.text;
        request.fields['owner_name'] = _ownerNameController.text.isNotEmpty
            ? _ownerNameController.text
            : 'Owner Name';
        request.fields['mobile_number'] = _mobileNumberController.text;
        request.fields['email'] = _emailController.text.isNotEmpty
            ? _emailController.text
            : '';
        request.fields['website'] = _websiteController.text;
        request.fields['address'] = _addressController.text;
        request.fields['category_id'] = _selectedCategoryId ?? '';
        request.fields['state_id'] = selectedState ?? '';

        if (_image != null) {
          var logoFile = await http.MultipartFile.fromPath(
            'logo',
            _image!.path,
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(logoFile);
        }
        var response = await request.send();

        if (response.statusCode == 200 || response.statusCode == 201) {

          _showSnackbar('Business profile submitted successfully!', Colors.green);
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
        } else {

          final errorMessage = await response.stream.bytesToString();

          String errorMsg = 'An unexpected error occurred. Please try again.';
          switch (response.statusCode) {
            case 400:
              errorMsg = 'The request could not be understood or was missing required parameters.';
              break;
            case 401:
              errorMsg = 'You are not authorized to perform this action. Please check your credentials.';
              break;
            case 403:
              errorMsg = 'You do not have permission to access this resource.';
              break;
            case 404:
              errorMsg = 'The requested resource was not found.';
              break;
            case 422:
              var errorJson = json.decode(errorMessage);
              if (errorJson['category_id'] != null) {
                errorMsg = 'Please select a category.';
              } else if (errorJson['website'] != null) {
                errorMsg = 'Please enter a valid website URL.';
              } else if (errorJson['state_id'] != null) {
                errorMsg = 'Please select a state.';
              }
              break;
            case 500:
              errorMsg = 'An unexpected error occurred on the server. Please try again later.';
              break;
            case 502:
              errorMsg = 'There was an issue connecting to the server. Please try again later.';
              break;
            case 503:
              errorMsg = 'The server is temporarily unavailable. Please try again later.';
              break;
            default:
              errorMsg = 'An unexpected error occurred. Please try again.';
              break;
          }


          _showSnackbar(errorMsg, Colors.red);


          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {

        _showSnackbar('An unexpected error occurred. Please try again.', Colors.red);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackbar(String message, Color color) {

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: color,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _navigateToCategorySelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectionScreen(
          onCategorySelected: (String categoryId, String categoryName) {
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

              buildLabel('Business Category', isRequired: true),
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
                      return 'Please enter a valid email ID';
                    }
                    return null;
                  }
                  return 'Please enter your email ID';
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
          Expanded(
            child: SizedBox(
              height: 50.h,
              child: OutlinedButton(
                onPressed: !_isLoading ? _clearForm : null,
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
          SizedBox(width: 16.w),
          Expanded(
            child: SizedBox(
              height: 50.h,
              child: ElevatedButton(
                onPressed: !_isLoading ? _submitBusinessProfile : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: _isLoading
                    ? SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: const CircularProgressIndicator(
                    color: Colors.red,
                    strokeWidth: 2.5,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
    );
  }

  void _clearForm() {
    setState(() {
      _image = null;
      selectedState = null;
      _formKey.currentState?.reset();
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

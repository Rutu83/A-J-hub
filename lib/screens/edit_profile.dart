// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, depend_on_referenced_packages

import 'package:allinone_app/network/rest_apis.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var UserId;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController(); // Added this for Date of Birth
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String selectedGender = 'Select Gender';
  String selectedCountryCode = '+91';
  String selectedDropdown1 = 'Select Sponsor';
  String selectedDropdown2 = 'Select Your Parent';
  bool _isLoading = true;
  List<String> sponsors = [];
  List<String> parents = [];

  Map<String, dynamic> userData = {};
  Future<Map<String, dynamic>>? futureUserDetail;
  UniqueKey keyForStatus = UniqueKey();

  void navigateBack() {
    Navigator.pop(context);
    snackBarMsgShow(context);
  }

  void tostMsgShow() {
    Navigator.pop(context);
    snackBarMsgShow1(context);

  }

  @override
  void initState() {
    super.initState();
    init();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    fetchUserData();
  }

  void init() async {
    futureUserDetail = getUserDetail();
    if (kDebugMode) {
      print('Hello User  $futureUserDetail');
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchUserData() async {
    try {
      Map<String, dynamic> userDetail = await getUserDetail();


      setState(() {
        UserId = userDetail['_id'];
        _firstNameController.text = userDetail['username'] ?? '';
        _emailController.text = userDetail['email'] ?? '';
        _phoneController.text = userDetail['phone_number'] ?? '';
        selectedGender = userDetail['gender'] ?? 'Select Gender';
        _dobController.text = userDetail['dob'] ?? '';
        _countryController.text = userDetail['country'] ?? '';
        _stateController.text = userDetail['state'] ?? '';
        _cityController.text = userDetail['district'] ?? '';
        selectedCountryCode = userDetail['country_code'] ?? '';
        _isLoading = false; // Set loading to false after data is fetched
      });

    } catch (e) {

      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
      setState(() {
        _isLoading = false; // Ensure loading state is false even on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    ScreenUtil.init(
      context,
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    if (_isLoading) {
      return Scaffold(
        body: _buildSkeletonLoader(), // Show skeleton loader while loading
      );
    }

    return Scaffold(
   appBar: AppBar(
     surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 2, // Slight shadow for depth
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black, // Icon color to match the theme
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 18.sp, // Adjust font size for readability
            fontWeight: FontWeight.w600, // Medium-bold weight for emphasis
            color: Colors.black, // Neutral black color for better visibility
          ),
        ),
      ),

      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 16.w,right: 16.w,bottom: 16.w,top: 6),
            child: Column(
              children: [

                _buildLogo(),

                Column(
                  children: [
                    _buildTextField(
                      'First Name',
                      'Enter First Name',
                      true,
                      _firstNameController,
                      enabled: true,
                      prefixIcon: Icons.person, // Icon for "First Name"
                    ),
                    _buildTextField(
                      'Email',
                      'Enter Your Email',
                      true,
                      _emailController,
                      enabled: false,
                      prefixIcon: Icons.email, // Icon for "Email"
                    ),
                    _buildTextField(
                      'Mobile Number',
                      'Enter Your Mobile Number',
                      true,
                      _phoneController,
                      enabled: false,
                      prefixIcon: Icons.phone, // Icon for "Mobile Number"
                    ),

                  ],
                ),
                // _buildPhoneNumberField(), // Will disable phone number field within this widget
                SizedBox(height: 6.h),
                _buildDropdownField('Gender', selectedGender, _selectGender, true), // Gender editable
                SizedBox(height: 8.h),
                _buildDateOfBirthField(), // Date of Birth editable
                // SizedBox(height: 6.h),
                _buildTextField(
                  'Country',
                  'Enter Country',
                  true,
                  _countryController,
                  enabled: false,
                  prefixIcon: Icons.public, // Icon for "Country"
                ),
                _buildTextField(
                  'State',
                  'Enter State',
                  true,
                  _stateController,
                  enabled: false,
                  prefixIcon: Icons.map, // Icon for "State"
                ),
                _buildTextField(
                  'City',
                  'Enter City',
                  true,
                  _cityController,
                  enabled: false,
                  prefixIcon: Icons.location_city, // Icon for "City"
                ),
                SizedBox(height: 16.h),

                ElevatedButton(
                  onPressed: () {
                    // Save action


                    setState(() {
                      _isLoading = true;
                    });

                    updateProfile(
                        name: _firstNameController.text,
                        gender: selectedGender,
                       dob: _dobController.text,

                        onSuccess: navigateBack,
                        onFail: tostMsgShow,
                    );

                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:  Text(
                  'Update',
                  style: GoogleFonts.roboto(
                    fontSize: 16.sp, // Responsive font size
                    fontWeight: FontWeight.w500, // Medium weight
                    color: Colors.white, // Text color
                    letterSpacing: 1.0, // Slight spacing for clarity
                  ),
                ),


          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      margin: EdgeInsets.all(6),
      padding: EdgeInsets.all(16.r), // Add padding around the logo
      decoration: BoxDecoration(
        color: Colors.white, // Background color for the logo container
        shape: BoxShape.circle, // Circular container for the logo
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Subtle shadow for depth
            blurRadius: 10,
            offset: const Offset(0, 5), // Shadow offset for a lifted effect
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade50, // Optional border color for aesthetics
          width: 2.0,
        ),
      ),
      child: Image.asset(
        'assets/images/app_logo2.png',
        height: 70.h, // Reduced height for better alignment
        width: 70.h,
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            _ageController.text = _calculateAge(pickedDate).toString();
          });
        }
      },
      child: AbsorbPointer(
        child: _buildTextField(
          'Date of Birth',
          'Select Date of Birth',
          true,
          _dobController,
          prefixIcon: Icons.calendar_today, // Calendar icon
        ),
      ),
    );
  }


  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month || (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Widget _buildTextField(
      String label,
      String hint,
      bool isRequired,
      TextEditingController controller, {
        bool isMultiline = false,
        bool enabled = true,
        IconData? prefixIcon,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, // Display the label above the text field
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 6.h), // Add spacing between label and text field
        Container(
          height: isMultiline ? null : 48.h,
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            keyboardType: isMultiline ? TextInputType.multiline : TextInputType.text,
            maxLines: isMultiline ? null : 1,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.roboto(
                textStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
              ),
              fillColor: Colors.grey.shade100, // Light background color for the text field
              filled: true,
              prefixIcon: prefixIcon != null
                  ? Icon(
                prefixIcon,
                color: Colors.red.shade400, // Icon color
              )
                  : null,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildDropdownField(
      String label,
      String value,
      void Function() onTap,
      bool isRequired,
      {IconData? prefixIcon} // Add optional icon parameter
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 6.h), // Spacing between title and dropdown
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48.h,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), // Subtle shadow
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (prefixIcon != null)
                  Icon(
                    prefixIcon,
                    color: Colors.red.shade400, // Prefix icon color
                    size: 20.sp,
                  ),
                SizedBox(width: 8.w), // Spacing between icon and text
                Expanded(
                  child: Text(
                    value.isNotEmpty ? value : 'Select $label',
                    style: GoogleFonts.roboto(
                      fontSize: 14.sp,
                      color: value.isNotEmpty
                          ? Colors.black
                          : Colors.grey.shade500, // Grey for placeholder
                    ),
                    overflow: TextOverflow.ellipsis, // Prevent overflow for long text
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  void _selectGender() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Male'),
                onTap: () {
                  setState(() {
                    selectedGender = 'Male';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Female'),
                onTap: () {
                  setState(() {
                    selectedGender = 'Female';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildSkeletonLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo Skeleton with shimmer
          _buildShimmerBox(width: 100.w, height: 100.h, borderRadius: 12.r),

          SizedBox(height: 20.h),

          // Form Field Skeletons with shimmer
          ...List.generate(2, (index) => _buildShimmerField()),

          // Additional placeholder for button or other elements
          SizedBox(height: 20.h),
          _buildShimmerBox(width: 150.w, height: 48.h, borderRadius: 12.r),
        ],
      ),
    );
  }

// Reusable Skeleton Box with Shimmer Effect
  Widget _buildShimmerBox({
    required double width,
    required double height,
    double borderRadius = 10.0,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade200,
            Colors.grey.shade300,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.2, 0.5, 0.8],
        ),
      ),
    );
  }

// Reusable Skeleton Field with Padding and Shimmer Effect
  Widget _buildShimmerField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      child: _buildShimmerBox(
        width: double.infinity,
        height: 48.h,
        borderRadius: 10.0,
      ),
    );
  }



  void snackBarMsgShow(BuildContext context) {
    const snackBar = SnackBar(
      content: Text(
        'successfully updated',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0),
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  void snackBarMsgShow1(BuildContext context) {
    const snackBar = SnackBar(
      content: Text(
        'failed to update',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0),
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}




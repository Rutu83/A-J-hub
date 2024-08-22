// ignore_for_file: use_build_context_synchronously


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  bool _isCityDropdownEnabled = false;
  String selectedCountryCode = '+91';
  String selectedCountry = 'India';
  String selectedDropdown1 = 'item';
  String selectedDropdown2 = 'item1';
  String selectedState = 'State';
  String selectedCity = 'City';
  String selectedGender = 'Select Gender';

  final Map<String, List<String>> stateCityMap = {
    'Gujarat': ['Ahmedabad', 'Anand', '	Bharuch','Bhavnagar', '	Gandhinagar', '	Banaskqantha'],
    'Maharashtra': ['Hingoli', 'Satara', 'Pune','Yavatmal', 'Dharashiv', 'Mumbai Suburban district'],
    'Karnataka': ['Bengaluru', 'Dharwad', 'Hassan','Ramanagara', 'Yadgir', 'Kolar'],
  };

  final Map<String, String> cityPinCodeMap = {
    'Ahmedabad': '380001',
    'Surat': '395003',
    'Vadodara': '390001',
    'Mumbai': '400001',
    'Pune': '411001',
    'Nagpur': '440001',
    'Bangalore': '560001',
    'Mysore': '570001',
    'Mangalore': '575001',
  };

  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();

  }



  //
  // Future<void> _registerUser() async {
  //   // print('Starting registration process...');
  //   //
  //   //
  //   //
  //   // print(fullNameController);
  //   // print(enagicEmailController);
  //   // print(contactNumberController);
  //   // print(bloodGroupController);
  //   // print(homeAddressController);
  //   // print(countryController);
  //   // print(stateController);
  //   // print(districtController);
  //   // print(cityController);
  //   // print(alternativeContactNumberController);
  //   // print(birthDateController);
  //   // print(dateOfBirthSpouseController);
  //   // print(anniversaryDateController);
  //   // print(teamIdController);
  //   // print(genderController);
  //   // print(statusController);
  //   // print(roleController);
  //   // print(cardNoController);
  //   // print(howMuchDeviceController);
  //   // print(userLevelController);
  //   // print(teamNameController);
  //   // print(teamLeaderNameController);
  //   // print(leaderRankController);
  //   // print(teamLeaderMobileController);
  //   // print(professionTypeController);
  //   // print(jobTypeController);
  //   // print(businessNameController);
  //   // print(passwordController);
  //   // print(confirmpasswordController);
  //
  //
  //   // Validate passwords match
  //   if (passwordController.text != confirmpasswordController.text) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Passwords do not match')),
  //     );
  //     return;
  //   }
  //
  //   // Collect all form data
  //   final formData = {
  //     'teamname': teamNameController.text,
  //     'full_name': fullNameController.text,
  //     'enagic_email': enagicEmailController.text,
  //     'contact_number': contactNumberController.text,
  //     'blood_group': bloodGroupController.text,
  //     'home_address': homeAddressController.text,
  //     'country': countryController.text,
  //     'state': stateController.text,
  //     'district': districtController.text,
  //     'city': cityController.text,
  //     'alternative_contact_number': alternativeContactNumberController.text,
  //     'birth_date': birthDateController.text,
  //     'date_of_birth_spouse': dateOfBirthSpouseController.text,
  //     'anniversary_date': anniversaryDateController.text,
  //     'team_id': teamIdController.text,
  //     'gender': genderController.text,
  //     'status': statusController.text,
  //     'role': roleController.text,
  //     'card_no': cardNoController.text,
  //     'how_much_device': howMuchDeviceController.text,
  //     'user_level': userLevelController.text,
  //     'team_leader_name': teamLeaderNameController.text,
  //     'leader_rank': leaderRankController.text,
  //     'team_leader_mobile': teamLeaderMobileController.text,
  //     'profession_type': professionTypeController.text,
  //     'job_type': jobTypeController.text,
  //     'business_name': businessNameController.text,
  //     'password': passwordController.text,
  //     'confirm_password': confirmpasswordController.text,
  //   };
  //
  //   const String apiUrl = 'https://ajsystem.in/api/register';
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       body: jsonEncode(formData),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //
  //     print('Response status: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       // ignore: use_build_context_synchronously
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Registered successfully')),
  //       );
  //
  //       // ignore: use_build_context_synchronously
  //       Navigator.pushReplacement(context, (MaterialPageRoute(builder: (context) => const LoginScreen())));
  //       // Navigate or handle success
  //     } else {
  //       // ignore: use_build_context_synchronously
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to register: ${response.body}')),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     // ignore: use_build_context_synchronously
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('An error occurred. Please try again.')),
  //     );
  //   }
  //
  //
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [


                Image.asset(
                  'assets/images/allinonenews.jpg',
                  height: 145.h,
                  width: 175.h,
                ),

                // Center(
                //   child: Stack(
                //     children: [
                //       CircleAvatar(
                //         radius: 50.r,
                //         backgroundColor: Colors.grey.shade200,
                //         child: ClipOval(
                //           child: _profileImageUrl != null
                //               ? Image.network(
                //             _profileImageUrl!,
                //             width: 100.r,
                //             height: 100.r,
                //             fit: BoxFit.cover,
                //           )
                //               : _profileImage != null
                //               ? Image.file(
                //             _profileImage!,
                //             width: 100.r,
                //             height: 100.r,
                //             fit: BoxFit.cover,
                //           )
                //               : Icon(Icons.person,
                //               size: 50.sp,
                //               color: Colors.grey),
                //         ),
                //       ),
                //       Positioned(
                //         bottom: 0,
                //         right: 0,
                //         child: GestureDetector(
                //           onTap:(){},
                //           child: Container(
                //             decoration: BoxDecoration(
                //               color: Colors.white,
                //               shape: BoxShape.circle,
                //               boxShadow: [
                //                 BoxShadow(
                //                   color: Colors.grey.withOpacity(0.5),
                //                   spreadRadius: 1,
                //                   blurRadius: 5,
                //                   offset: const Offset(0, 3),
                //                 ),
                //               ],
                //             ),
                //             child: Icon(Icons.edit,
                //                 color: Colors.black, size: 20.sp),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: 24.h),
                _buildTextField('First Name', 'First Name', true,
                    _firstNameController),
                SizedBox(height: 16.h),
                // _buildTextField(
                //     'Last Name', 'Last Name', true, _lastNameController),
                // SizedBox(height: 16.h),
                _buildTextField('Email', 'Email', true, _emailController,
                    enabled: false),
                SizedBox(height: 16.h),
                _buildPhoneNumberField(),
                SizedBox(height: 16.h),
                // Row(
                //   children: [
                //     Expanded(
                //         child: _buildDropdownField('Gender',
                //             selectedGender, _selectGender, true)),
                //     SizedBox(width: 16.w),
                //     Expanded(
                //         child: _buildDateField(
                //             'Date of Birth', _dateController, true)),
                //   ],
                // ),
                // SizedBox(height: 16.h),
                _buildTextField('Address', 'Enter Your Address Here', true,
                    _addressController,
                    isMultiline: true),
                SizedBox(height: 16.h),
                _buildDropdownField(
                    'Country', selectedCountry, _selectCountry, true),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(child: _buildStateDropdown()),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildCityDropdown()),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildDropdownField(
                    'Dropdown 1', selectedDropdown1, _selectCountry, true),
                SizedBox(height: 16.h),
                _buildDropdownField(
                    'Dropdown 2', selectedDropdown2, _selectCountry, true),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: (){},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:  const Text('Sign up', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, bool isRequired,
      TextEditingController controller,
      {bool isMultiline = false, bool isPhone = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [        Row(
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isRequired)
            Text('*', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
        ],
      ),

        SizedBox(height: 4.h),
        Container(
          height: 48.h,
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            maxLines: isMultiline ? null : 1,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Phone Number',
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text('*', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: true,
                  onSelect: (Country country) {
                    setState(() {
                      selectedCountryCode = '+${country.phoneCode}';
                    });
                  },
                );
              },
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Text(
                      selectedCountryCode,
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(
                height: 48.h,
                alignment: Alignment.center,
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, void Function() onTap, bool isRequired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isRequired)
              Text('*', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 4.h),
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
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildDateField(String label, TextEditingController controller, bool isRequired) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Text(
  //             label,
  //             style: GoogleFonts.roboto(
  //               textStyle: TextStyle(
  //                 color: Colors.black,
  //                 fontSize: 14.sp,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //           if (isRequired)
  //             Text('*', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
  //         ],
  //       ),
  //       SizedBox(height: 4.h),
  //       GestureDetector(
  //         onTap: () async {
  //
  //
  //         },
  //         child: Container(
  //           height: 48.h,
  //           alignment: Alignment.center,
  //           padding: EdgeInsets.symmetric(horizontal: 12.w),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             border: Border.all(color: Colors.grey.shade400),
  //             borderRadius: BorderRadius.circular(10.r),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 controller.text.isEmpty ? 'Select Date' : controller.text,
  //                 style: GoogleFonts.roboto(
  //                   textStyle: TextStyle(
  //                     color: Colors.black,
  //                     fontSize: 14.sp,
  //                   ),
  //                 ),
  //               ),
  //               const Icon(Icons.calendar_today, color: Colors.black),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'State',
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text('*', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: stateCityMap.keys.map((state) {
                      return ListTile(
                        title: Text(state),
                        onTap: () {
                          setState(() {
                            selectedState = state;
                            selectedCity = 'City'; // Reset city when state changes
                            _isCityDropdownEnabled = true; // Enable city dropdown
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
          child: Container(
            height: 48.h,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedState,
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'District',
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text('*', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: _isCityDropdownEnabled
              ? () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: stateCityMap[selectedState]?.map((city) {
                      return ListTile(
                        title: Text(city),
                        onTap: () {
                          setState(() {
                            selectedCity = city;
                            _postalCodeController.text = cityPinCodeMap[city] ?? '';
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    }).toList() ?? [],
                  ),
                );
              },
            );
          }
              : null,
          child: Container(
            height: 48.h,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _isCityDropdownEnabled
                    ? Colors.grey.shade400
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCity,
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: _isCityDropdownEnabled
                          ? Colors.black
                          : Colors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
  }



  //
  // void _selectGender() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         padding: EdgeInsets.all(16.w),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             ListTile(
  //               title: const Text('Male'),
  //               onTap: () {
  //                 setState(() {
  //                   selectedGender = 'Male';
  //                 });
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //             ListTile(
  //               title: const Text('Female'),
  //               onTap: () {
  //                 setState(() {
  //                   selectedGender = 'Female';
  //                 });
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void _selectCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          selectedCountry = country.name;
        });
      },
    );
  }
}




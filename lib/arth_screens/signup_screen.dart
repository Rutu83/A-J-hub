import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();  // Added this for Date of Birth
  final TextEditingController _ageController = TextEditingController();
  String selectedGender = 'Select Gender';

  bool _isCityDropdownEnabled = false;
  String selectedCountryCode = '+91';
  String selectedCountry = 'India';
  String selectedState = 'State';
  String selectedCity = 'City';
  String selectedDropdown1 = 'Select Sponsor';
  String selectedDropdown2 = 'Select Your Parent';

  final List<String> states = ['Gujarat', 'Maharashtra', 'Karnataka'];
  final Map<String, List<String>> stateCityMap = {
    'Gujarat': ['Ahmedabad', 'Anand', 'Bharuch', 'Bhavnagar', 'Gandhinagar', 'Banaskantha'],
    'Maharashtra': ['Hingoli', 'Satara', 'Pune', 'Yavatmal', 'Dharashiv', 'Mumbai Suburban district'],
    'Karnataka': ['Bengaluru', 'Dharwad', 'Hassan', 'Ramanagara', 'Yadgir', 'Kolar'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                SizedBox(height: 15.h),
                Image.asset(
                  'assets/images/aj3.jpg',
                  height: 100.h,
                  width: 100.h,
                ),
                SizedBox(height: 24.h),
                _buildTextField('First Name', 'Enter First Name', true, _firstNameController),
                SizedBox(height: 16.h),
                _buildTextField('Email', 'Enter Your Email', true, _emailController, enabled: false),
                SizedBox(height: 16.h),
                _buildPhoneNumberField(),
                SizedBox(height: 16.h),
                _buildDropdownField('Gender',
                    selectedGender, _selectGender, true),
                SizedBox(height: 16.h),
                _buildDateOfBirthField(),
                SizedBox(height: 16.h),
                _buildTextField('Age', 'Enter Your Age', true, _ageController, enabled: false),
                SizedBox(height: 16.h),

                _buildDropdownField('Country', selectedCountry, _selectCountry, true),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(child: _buildStateDropdown()),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildCityDropdown()),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildDropdownField('Select Sponsor', selectedDropdown1, _selectDropdown1, true),
                SizedBox(height: 16.h),
                _buildDropdownField('Select Your Parent', selectedDropdown2, _selectDropdown2, true),
                SizedBox(height: 16.h),
                _buildTextField('Password', 'Enter Your Password', true, _passwordController, isMultiline: false),
                SizedBox(height: 16.h),
                _buildTextField('Confirm Password', 'Confirm Your Password', true, _confirmPasswordController, isMultiline: false),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
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
            _ageController.text = _calculateAge(pickedDate).toString(); // Update age automatically
          });
        }
      },
      child: AbsorbPointer(
        child: Expanded(child: _buildTextField2('Date of Birth', 'Select Date of Birth', true, _dobController)),
      ),
    );
  }

  // Calculate Age based on Date of Birth
  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month || (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }



  Widget _buildTextField2(String label, String hint, bool isRequired, TextEditingController controller,
      {bool isMultiline = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4.h),
        Container(
          height: isMultiline ? null : 48.h,
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            maxLines: isMultiline ? null : 1,
            enabled: enabled,

            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: const Icon(Icons.calendar_month),
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


  Widget _buildTextField(String label, String hint, bool isRequired, TextEditingController controller,
      {bool isMultiline = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4.h),
        Container(
          height: isMultiline ? null : 48.h,
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
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

  Widget _buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   children: [
        //     Text(
        //       'State',
        //       style: GoogleFonts.roboto(
        //         textStyle: TextStyle(
        //           color: Colors.black,
        //           fontSize: 14.sp,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //     ),
        //     Text('*', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
        //   ],
        // ),
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
        // Row(
        //   children: [
        //     Text(
        //       'District',
        //       style: GoogleFonts.roboto(
        //         textStyle: TextStyle(
        //           color: Colors.black,
        //           fontSize: 14.sp,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //     ),
        //     Text('*', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
        //   ],
        // ),
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

  void _selectCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          selectedCountry = country.name;
          selectedCountryCode = '+${country.phoneCode}';
        });
      },
    );
  }

  void _selectDropdown1() {
    // Implement your dropdown 1 selection logic here
  }

  void _selectDropdown2() {
    // Implement your dropdown 2 selection logic here
  }


}

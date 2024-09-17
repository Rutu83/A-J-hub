// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController(); // Added this for Date of Birth
  final TextEditingController _ageController = TextEditingController();
  String selectedGender = 'Select Gender';
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;

  List<dynamic> countries = [];
  List<dynamic> states = [];
  List<dynamic> cities = [];
  String selectedCountryCode = '+91';
  String selectedDropdown1 = 'Select Sponsor';
  String selectedDropdown2 = 'Select Your Parent';
   bool _isLoading = false;
  List<String> sponsors = [];
  List<String> parents = [];

  @override
  void initState() {
    super.initState();
    fetchDropdownData(); // Call the API when the screen initializes
    fetchCountries();
  }

  // Fetch countries
  Future<void> fetchCountries() async {
    final response = await http.get(Uri.parse('https://ajhub.co.in/get-states-regby-country/{countryId}'));
    if (response.statusCode == 200) {
      setState(() {
        countries = json.decode(response.body);  // Assuming the response is in JSON format
      });
    } else {
      throw Exception('Failed to load countries');
    }
  }

  // Fetch states based on country selection
  Future<void> fetchStates(String countryId) async {
    final response = await http.get(Uri.parse('https://ajhub.co.in/get-states-regby-country/91'));
    if (response.statusCode == 200) {
      setState(() {
        states = json.decode(response.body); // Parse states from response
        cities = []; // Clear the cities when a new state is selected
        selectedState = null;
        selectedCity = null;
      });
    } else {
      throw Exception('Failed to load states');
    }
  }

  // Fetch cities based on state selection
  Future<void> fetchCities(String stateId) async {
    final response = await http.get(Uri.parse('https://ajhub.co.in/get-districts-regby-state/$stateId'));
    if (response.statusCode == 200) {
      setState(() {
        cities = json.decode(response.body); // Parse cities (districts) from response
        selectedCity = null;
      });
    } else {
      throw Exception('Failed to load cities');
    }
  }

  Future<void> fetchDropdownData() async {
    final response = await http.get(Uri.parse('https://ajhub.co.in/search-user'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        sponsors = data.map<String>((user) => user['username'].toString()).toList();
        parents = data.map<String>((user) => user['username'].toString()).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }










  Future<void> _registerUser() async {
    // Validate fields (Example: Ensure passwords match)
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (selectedDropdown1 == 'Select Sponsor' || selectedDropdown2 == 'Select Your Parent') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both Sponsor and Parent')));
      return;
    }

    // Show a loading indicator
    setState(() {
      _isLoading = true;
    });

    // Define the API URL
    const String apiUrl = 'https://ajhub.co.in/api/register';

    // Create the request payload
    final Map<String, dynamic> payload = {
      "username": _firstNameController.text,
      "email": _emailController.text,
      "phone_number": _phoneController.text,
      "password": _passwordController.text.trim(),
      "password_confirmation": _confirmPasswordController.text.trim(),
      "gender": selectedGender,
      "dob": _dobController.text,
      "country_id": selectedCountry ?? '1',
      "state": selectedState ?? 'Gujarat',
      "district": selectedCity ?? 'Banaskantha',
      "sponsor": selectedDropdown1,
      "parent": selectedDropdown2,
    };


    // Send the POST request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );


    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Successful')));
    } else if (response.statusCode == 500) {
      final responseData = json.decode(response.body);
      print(responseData);

      // Check for specific error message and provide user-friendly feedback
      String errorMessage = responseData['message'] ?? 'An unexpected error occurred. Please try again later.';

      // You can handle specific server error messages if needed
      if (responseData['error'] != null && responseData['error'].contains('handleLevelIncome')) {
        errorMessage = 'A server issue occurred during registration. Please contact support.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } else {
      print(response.statusCode);
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Failed')));
    }



    // Hide the loading indicator
    setState(() {
      _isLoading = false;
    });
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
                _buildTextField('Email', 'Enter Your Email', true, _emailController),
                SizedBox(height: 16.h),
                _buildPhoneNumberField(),
                SizedBox(height: 16.h),
                _buildDropdownField('Gender', selectedGender, _selectGender, true),
                SizedBox(height: 16.h),
                _buildDateOfBirthField(),
                SizedBox(height: 16.h),
                _buildTextField('Age', 'Enter Your Age', true, _ageController),
                SizedBox(height: 16.h),

                // Country Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCountry,
                  hint: const Text('Select Country'),
                  items: countries.map<DropdownMenuItem<String>>((country) {
                    return DropdownMenuItem<String>(
                      value: country['id'].toString(),
                      child: Text(country['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCountry = value;
                    });
                    fetchStates(value!);
                  },
                ),
                const SizedBox(height: 16),

                // State Dropdown
                DropdownButtonFormField<String>(
                  value: selectedState,
                  hint: const Text('Select State'),
                  items: states.map<DropdownMenuItem<String>>((state) {
                    return DropdownMenuItem<String>(
                      value: state['id'].toString(),
                      child: Text(state['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                    });
                    fetchCities(value!);
                  },
                ),
                const SizedBox(height: 16),

                // City Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  hint: const Text('Select City'),
                  items: cities.map<DropdownMenuItem<String>>((city) {
                    return DropdownMenuItem<String>(
                      value: city['id'].toString(),
                      child: Text(city['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                ),
                SizedBox(height: 16.h),

                // Autocomplete for Sponsor
                _buildAutoCompleteField('Select Sponsor', sponsors, (String selection) {
                  setState(() {
                    selectedDropdown1 = selection;
                  });
                }),

                SizedBox(height: 16.h),

                // Autocomplete for Parent
                _buildAutoCompleteField('Select Your Parent', parents, (String selection) {
                  setState(() {
                    selectedDropdown2 = selection;
                  });
                }),

                SizedBox(height: 16.h),
                _buildTextField('Password', 'Enter Your Password', true, _passwordController, isMultiline: false),
                SizedBox(height: 16.h),
                _buildTextField('Confirm Password', 'Confirm Your Password', true, _confirmPasswordController, isMultiline: false),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () {

                    _registerUser();
                  },
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
        child: _buildTextField('Date of Birth', 'Select Date of Birth', true, _dobController),
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

  Widget _buildPhoneNumberField() {
    return Row(
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

  Widget _buildDropdownField(String label, String value, void Function() onTap, bool isRequired) {
    return GestureDetector(
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
    );
  }

  Widget _buildAutoCompleteField(
      String label, List<String> items, Function(String) onSelected) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return items.where((item) {
          return item.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        onSelected(selection);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: label,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        );
      },
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
}

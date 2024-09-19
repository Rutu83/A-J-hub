// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, depend_on_referenced_packages

import 'dart:convert';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final bool _isLoading = false;
  List<String> sponsors = [];
  List<String> parents = [];
  bool _isLoadingCountries = false;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;


  Map<String, dynamic> userData = {};
  Future<Map<String, dynamic>>? futureUserDetail;
  UniqueKey keyForStatus = UniqueKey();

  @override
  void initState() {
    super.initState();
    init();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    fetchUserData();
    fetchCountries();
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
      if (kDebugMode) {
        print('...........................................................');
        print(userDetail);
      }

      setState(() {
        UserId = userDetail['_id'];
        _firstNameController.text = userDetail['username'] ?? '';
        _emailController.text = userDetail['email'] ?? '';
        _phoneController.text = userDetail['phone_number'] ?? '';
        selectedGender = userDetail['gender'] ?? 'Select Gender';
        _dobController.text = userDetail['dob'] ?? '';
        selectedCountry = userDetail['country'] ?? '';
        selectedState = userDetail['state'] ?? '';
        selectedCity = userDetail['district'] ?? '';
        selectedCountryCode = userDetail['country_code'] ?? '';
      });

      // Automatically fetch states after setting country
      if (selectedCountry != null && selectedCountry!.isNotEmpty) {
        fetchStates(selectedCountry!);  // Fetch states for the selected country
      }

      // Automatically fetch cities after setting state
      if (selectedState != null && selectedState!.isNotEmpty) {
        fetchCities(selectedState!);  // Fetch cities for the selected state
      }

    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
    }
  }




  Future<void> fetchCountries() async {
    setState(() {
      _isLoadingCountries = true;
    });

    try {
      final response = await http.get(Uri.parse('https://ajhub.co.in/api/get-country'));
      if (response.statusCode == 200) {
        List<dynamic> countryList = json.decode(response.body);

        // Optional: Remove duplicates based on 'id' or 'name'
        List<dynamic> uniqueCountries = countryList.toSet().toList();

        setState(() {
          countries = uniqueCountries;
          _isLoadingCountries = false;

          // Check if the user's selectedCountry exists in the API country list
          if (selectedCountry!.isNotEmpty) {
            bool countryExists = countries.any((country) => country['name'] == selectedCountry);
            if (!countryExists) {
              // If country is not found, let the user enter the country manually
              selectedCountry = '';  // Reset to allow manual input if needed
            }
          }
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
      setState(() {
        _isLoadingCountries = false;
      });
    }
  }



  Future<void> fetchStates(String countryId) async {
    setState(() {
      _isLoadingStates = true;
    });

    try {
      final response = await http.get(Uri.parse('https://ajhub.co.in/get-states-regby-country/$countryId'));
      if (response.statusCode == 200) {
        List<dynamic> stateList = json.decode(response.body);

        setState(() {
          states = stateList;
          cities = [];  // Reset cities when states are fetched
          selectedCity = null;

          // Check if the stored selectedState is in the fetched list
          if (selectedState!.isNotEmpty) {
            bool stateExists = states.any((state) => state['name'] == selectedState);
            if (!stateExists) {
              selectedState = '';  // Reset if state is not found
            }
          }

          _isLoadingStates = false;
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
      setState(() {
        _isLoadingStates = false;
      });
    }
  }


  Future<void> fetchCities(String stateId) async {
    setState(() {
      _isLoadingCities = true;
    });

    try {
      final response = await http.get(Uri.parse('https://ajhub.co.in/get-districts-regby-state/$stateId'));
      if (response.statusCode == 200) {
        List<dynamic> cityList = json.decode(response.body);

        setState(() {
          cities = cityList;

          // Check if the stored selectedCity is in the fetched list
          if (selectedCity!.isNotEmpty) {
            bool cityExists = cities.any((city) => city['name'] == selectedCity);
            if (!cityExists) {
              selectedCity = '';  // Reset if city is not found
            }
          }

          _isLoadingCities = false;
        });
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
        _isLoadingCities = false;
      });
    }
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

                // Country Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCountry!.isEmpty ? null : selectedCountry,  // Set the value to `null` if country is not found
                  decoration: InputDecoration(
                    labelText: 'Select Country',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  ),
                  isExpanded: true,
                  items: countries.map<DropdownMenuItem<String>>((country) {
                    return DropdownMenuItem<String>(
                      value: country['name'],  // Match by country name
                      child: Text(country['name']),
                    );
                  }).toSet().toList(),  // Use a Set to ensure unique values
                  onChanged: (value) {
                    setState(() {
                      selectedCountry = value;
                    });
                    fetchStates(value!);
                  },
                ),


                if (_isLoadingCountries) const CircularProgressIndicator(),
                SizedBox(height: 16.h),

                // State Dropdown
                DropdownButtonFormField<String>(
                  value: selectedState,
                  decoration: InputDecoration(
                    labelText: 'Select State',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  ),
                  isExpanded: true,
                  items: states.map<DropdownMenuItem<String>>((state) {
                    return DropdownMenuItem<String>(
                      value: state['name'],  // Use state name
                      child: Text(state['name']),
                    );
                  }).toList(),  // Ensure the list contains unique states
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;  // Set the selected state
                    });
                    fetchCities(value!);  // Fetch cities for the selected state
                  },
                ),

                if (_isLoadingStates) const CircularProgressIndicator(),
                SizedBox(height: 16.h),

            // City Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  decoration: InputDecoration(
                    labelText: 'Select City',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  ),
                  isExpanded: true,
                  items: cities.map<DropdownMenuItem<String>>((city) {
                    return DropdownMenuItem<String>(
                      value: city['name'],  // Use city name
                      child: Text(city['name']),
                    );
                  }).toList(),  // Ensure the list contains unique cities
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;  // Set the selected city
                    });
                  },
                ),

                if (_isLoadingCities) const CircularProgressIndicator(),
                SizedBox(height: 16.h),

                SizedBox(height: 16.h),

                ElevatedButton(
                  onPressed: () {
                    // Save action
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

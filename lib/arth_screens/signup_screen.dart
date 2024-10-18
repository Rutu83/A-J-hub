// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:allinone_app/arth_screens/login_screen.dart';
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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  bool isLocationError = false;
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
  bool _isLoadingCountries = false;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;
  bool _isGenderError = false;
  @override
  void initState() {
    super.initState();
    fetchDropdownData(); // Call the API when the screen initializes
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    setState(() {
      _isLoadingCountries = true;
    });

    try {
      final response = await http.get(Uri.parse('https://ajhub.co.in/api/get-country'));
      if (response.statusCode == 200) {
        setState(() {
          countries = json.decode(response.body);
          _isLoadingCountries = false;
        });
      } else {
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
      print(e);
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
        setState(() {
          states = json.decode(response.body);
          cities = [];
          selectedState = null;
          selectedCity = null;
          _isLoadingStates = false;
        });
      } else {
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
      print(e);
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
        setState(() {
          cities = json.decode(response.body);
          selectedCity = null;
          _isLoadingCities = false;
        });
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoadingCities = false;
      });
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
    if (selectedDropdown1 == 'Select Sponsor' || selectedDropdown2 == 'Select Your Parent') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both Sponsor and Parent')));
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      const String apiUrl = 'https://ajhub.co.in/api/register';
      final Map<String, dynamic> payload = {
        "username": _firstNameController.text,
        "email": _emailController.text,
        "phone_number": _phoneController.text,
        "password": _passwordController.text.trim(),
        "password_confirmation": _confirmPasswordController.text.trim(),
        "gender": selectedGender,
        "dob": _dobController.text,
        "country_id": selectedCountry,
        "state": selectedState,
        "district": selectedCity,
        "sponsor": selectedDropdown1,
        "parent": selectedDropdown2,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Successful')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else {
        final responseData = json.decode(response.body);
        String errorMessage = responseData['message'] ?? 'An unexpected error occurred. Please try again later.';

        if (response.statusCode == 500) {
          errorMessage = responseData['error'] != null && responseData['error'].contains('handleLevelIncome')
              ? 'A server issue occurred during registration. Please contact support.'
              : 'Server error. Please try again later.';
        } else if (response.statusCode == 400) {
          errorMessage = 'Validation error. Please check the input fields and try again.';
        } else if (response.statusCode == 403) {
          errorMessage = 'You are not authorized to perform this action.';
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }

      setState(() {
        _isLoading = false;
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Image.asset(
                    'assets/images/aj3.jpg',
                    height: 120.h,
                    width: 120.h,
                  ),
                  SizedBox(height: 10.h),
                  _buildTextField('First Name', 'Enter First Name', true, _firstNameController),
                  SizedBox(height: 10.h),
                  _buildTextField('Email', 'Enter Your Email', true, _emailController),
                  SizedBox(height: 10.h),
                  _buildPhoneNumberField(),
                  SizedBox(height: 10.h),
                  _buildDropdownField(
                      'Gender',
                      selectedGender,
                      _selectGender,
                      true
                  ),
                  SizedBox(height: 10.h),
                  _buildDateOfBirthField(),
                  SizedBox(height: 10.h),
                  _buildTextField('Age', 'Enter Your Age', true, _ageController),
                  SizedBox(height: 10.h),
                  if (_isLoadingCountries) const CircularProgressIndicator(),
                  _buildCountryDropdown(),
                  SizedBox(height: 10.h),
                  if (_isLoadingStates) const CircularProgressIndicator(),
                  _buildStateDropdown(),
                  SizedBox(height: 10.h),
                  if (_isLoadingCities) const CircularProgressIndicator(),
                  _buildCityDropdown(),
                  SizedBox(height: 10.h),
                  _buildAutoCompleteField('Select Sponsor', sponsors, (String selection) {
                    setState(() {
                      selectedDropdown1 = selection;
                    });
                  }),
                  SizedBox(height: 10.h),
                  _buildAutoCompleteField('Select Your Parent', parents, (String selection) {
                    setState(() {
                      selectedDropdown2 = selection;
                    });
                  }),
                  SizedBox(height: 10.h),
                  _buildTextField('Password', 'Enter Your Password', true, _passwordController, isMultiline: false),
                  SizedBox(height: 10.h),
                  _buildTextField('Confirm Password', 'Confirm Your Password', true, _confirmPasswordController, isMultiline: false),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isGenderError = selectedGender == 'Select Gender';
                      });
                      if (_formKey.currentState!.validate() && !_isGenderError) {
                        _registerUser();
                      }
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
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: isLocationError ? const EdgeInsets.only(bottom: 24) : EdgeInsets.zero, // Add padding if error
            child: GestureDetector(
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
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: isLocationError ?  Colors.red: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Text(
                      selectedCountryCode,
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
              ),
            ),
            ),

            SizedBox(width: 8.w), // Space between country picker and phone number field
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: TextFormField(
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
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.red.shade400),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        isLocationError = true;
                      });
                      return 'Please enter your phone number';
                    }
                    setState(() {
                      isLocationError = false;
                    });
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildTextField(String label, String hint, bool isRequired, TextEditingController controller, {bool isMultiline = false, bool enabled = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      maxLines: isMultiline ? null : 1,
      enabled: enabled,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Value can\'t be empty'; // Error message for empty fields
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorStyle: const TextStyle(
          color: Colors.red, // Error message text color
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }




  Widget _buildCountryDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCountry,
        hint: const Text('Select Country'),
        isExpanded: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.red.shade400),
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a country';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildStateDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedState,
        hint: const Text('Select State'),
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.red.shade400),
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a state';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCity,
        hint: const Text('Select City'),
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.red.shade400),
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a city';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAutoCompleteField(String label, List<String> items, Function(String) onSelected) {
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
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: label,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.red.shade400), // Red border on error
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildDropdownField(String label, String value, void Function() onTap, bool isRequired) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: _isGenderError ? Colors.red : Colors.grey.shade400,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  color: _isGenderError ? Colors.red : Colors.black,
                  fontSize: 12.sp,
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
                    _isGenderError = false;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Female'),
                onTap: () {
                  setState(() {
                    selectedGender = 'Female';
                    _isGenderError = false;
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


  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    String pattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
}

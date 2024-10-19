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
  bool _isPasswordVisible = false;  // Flag to toggle password visibility
  bool _isConfirmPasswordVisible = false;  // Flag to toggle confirm password visibility
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  bool isLocationError = false;
  bool _isPhoneNumberValid = true;
  bool _isPasswordValid = true;


  bool _isEmailValid = true;  // Email validation flag

  String selectedGender = 'Select Gender';
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  bool _passwordsMatch = true;
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

    _passwordController.addListener(_checkPasswords);
    _confirmPasswordController.addListener(_checkPasswords);
    _phoneController.addListener(_validatePhoneNumber);
    _emailController.addListener(_validateEmail);
  }


  void _showCountrySelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows full-screen scrolling behavior
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0), // Set top-left corner radius
          topRight: Radius.circular(30.0), // Set top-right corner radius
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false, // Prevents expanding to full screen on its own
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white, // Set background color to white
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0), // Ensure top-left corner is rounded
                  topRight: Radius.circular(30.0), // Ensure top-right corner is rounded
                ),
              ),
              child: Column(
                children: [

                  const SizedBox(
                    height: 20,
                  ),

                  Container(
                    height: 6,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12)
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Title for the bottom sheet

                  Container(
                    alignment: Alignment.centerLeft,
                    child:   Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Select Country',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController, // Attach the scroll controller
                      itemCount: countries.length,
                      itemBuilder: (context, index) {
                        final country = countries[index];
                        return ListTile(
                          title: Text(country['name']),
                          onTap: () {
                            setState(() {
                              selectedCountry = country['name'];
                            });
                            fetchStates(country['id'].toString()); // Fetch states based on country selection
                            Navigator.pop(context);
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider( // Horizontal line between items
                          thickness: 1,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStateSelectionSheet() {
    if (selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a country first')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows full-screen scrolling behavior
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0), // Set top-left corner radius
          topRight: Radius.circular(30.0), // Set top-right corner radius
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false, // Prevents expanding to full screen on its own
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white, // Set background color to white
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0), // Ensure top-left corner is rounded
                  topRight: Radius.circular(30.0), // Ensure top-right corner is rounded
                ),
              ),
              child: Column(
                children: [

                  const SizedBox(
                    height: 20,
                  ),

                  Container(
                    height: 6,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12)
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Title for the bottom sheet

                  Container(
                    alignment: Alignment.centerLeft,
                    child:   Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Select State',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),


                  Expanded(
                    child: ListView.separated(
                      controller: scrollController, // Attach the scroll controller
                      itemCount: states.length,
                      itemBuilder: (context, index) {
                        final state = states[index];
                        return ListTile(
                          title: Text(state['name']),
                          onTap: () {
                            setState(() {
                              selectedState = state['name'];
                            });
                            fetchCities(state['id'].toString()); // Fetch cities based on state selection
                            Navigator.pop(context);
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider( // Horizontal line between items
                          thickness: 1,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCitySelectionSheet() {
    if (selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a state first')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows full-screen scrolling behavior
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0), // Set top-left corner radius
          topRight: Radius.circular(30.0), // Set top-right corner radius
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false, // Prevents expanding to full screen on its own
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white, // Set background color to white
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0), // Ensure top-left corner is rounded
                  topRight: Radius.circular(30.0), // Ensure top-right corner is rounded
                ),
              ),
              child: Column(
                children: [

                  const SizedBox(
                    height: 20,
                  ),

                  Container(
                    height: 6,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12)
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Title for the bottom sheet

                  Container(
                    alignment: Alignment.centerLeft,
                    child:   Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Select City',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      controller: scrollController, // Attach the scroll controller
                      itemCount: cities.length,
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return ListTile(
                          title: Text(city['name']),
                          onTap: () {
                            setState(() {
                              selectedCity = city['name'];
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider( // Horizontal line between items
                          thickness: 1,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }





  // Real-time email validation
  void _validateEmail() {
    setState(() {
      _isEmailValid = _isValidEmail(_emailController.text);
    });
  }

  // Email validation regex
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegExp.hasMatch(email);
  }



  // Check passwords and validate password length
  void _checkPasswords() {
    setState(() {
      _passwordsMatch = _passwordController.text == _confirmPasswordController.text;
      _isPasswordValid = _passwordController.text.length >= 6;
    });
  }

  @override
  void dispose() {
    // Dispose controllers when no longer needed to free up resources
    _passwordController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  // Phone number validation logic
  void _validatePhoneNumber() {
    setState(() {
      // Check if phone number is not empty and matches basic validation (adjust regex based on your needs)
      _isPhoneNumberValid = _phoneController.text.isNotEmpty && _isValidPhoneNumber(_phoneController.text);
    });
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    final phoneRegExp = RegExp(r'^\+?\d{10,15}$'); // Simple phone number validation (adjust as needed)
    return phoneRegExp.hasMatch(phoneNumber);
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
    if (selectedCountry == null || selectedState == null || selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Country, State, and City')),
      );
      setState(() {
        // Trigger validation errors
        isLocationError = true;
      });
      return;
    }

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
                    'assets/images/app_logo2.png',
                    height: 120.h,
                    width: 120.h,
                  ),
                  SizedBox(height: 10.h),
                  _buildTextField('First Name', 'Enter First Name', true, _firstNameController),


                  SizedBox(height: 10.h),
                  _buildEmailField(),
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
                  _buildCountryField(),
                  SizedBox(height: 10.h),
                  if (_isLoadingStates) const CircularProgressIndicator(),
                  _buildStateField(),
                  SizedBox(height: 10.h),
                  if (_isLoadingCities) const CircularProgressIndicator(),
                  _buildCityField(),

                  SizedBox(height: 10.h),
                  _buildPasswordField(),
                  SizedBox(height: 10.h),
                  _buildConfirmPasswordField(),
                  if (!_passwordsMatch)
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Passwords do not match',
                        style: TextStyle(color: Colors.red.shade900, fontSize: 12.sp),
                      ),
                    ),


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

                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Set error flags if these fields are not selected
                        isLocationError = selectedCountry == null || selectedState == null || selectedCity == null;
                        _isGenderError = selectedGender == 'Select Gender';
                      });

                      // Check if all form fields are valid before processing registration
                      if (_formKey.currentState!.validate() && !_isGenderError && !isLocationError) {
                        _registerUser();
                      } else {
                        // Display error if country, state, or city is not selected
                        if (isLocationError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select Country, State, and City')),
                          );
                        }
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
                  )

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

  // Phone number input field with real-time validation
  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              child: Column(
                children: [

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: _isPhoneNumberValid ? Colors.grey.shade400 : Colors.red.shade900),
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



                  // Conditionally add padding or space if the phone number is invalid
                  if (!_isPhoneNumberValid)
                    Container(
                      height: 29,
                      width: 10,
                   //  color: Colors.blue,
                      // padding: EdgeInsets.only(bottom: 90.0),  // Add space at the bottom when error is shown
                    ),
                ],
              ),

            ),
                const SizedBox(
                  width: 8,
                ),

            // Phone Number Input Field
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: _isPhoneNumberValid ? Colors.grey.shade400 : Colors.red),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: _isPhoneNumberValid ? Colors.black : Colors.red),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.red.shade900),
                    ),
                    errorText: _isPhoneNumberValid ? null : 'Please enter a valid phone number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
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


  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,  // Toggle visibility
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        labelStyle: TextStyle(color: _passwordsMatch ? Colors.black : Colors.red.shade900),
        errorText: !_isPasswordValid ? 'Password must be at least 6 characters long' : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _isPasswordValid ? Colors.grey : Colors.red.shade900),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _isPasswordValid ? Colors.black : Colors.red.shade900),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;  // Toggle visibility
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }

  // Confirm password field with eye icon
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,  // Toggle visibility
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter your password',
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        labelStyle: TextStyle(color: _passwordsMatch ? Colors.black : Colors.red.shade900),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _passwordsMatch ? Colors.grey : Colors.red.shade900),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _passwordsMatch ? Colors.grey : Colors.red.shade900),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _passwordsMatch ? Colors.black : Colors.red.shade900),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;  // Toggle visibility
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }






Widget _buildTextField(String label, String hint, bool isRequired, TextEditingController controller,
      {bool isMultiline = false, bool enabled = true, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: isMultiline ? null : 1,
      enabled: enabled,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$label can\'t be empty'; // Error message for empty fields
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        labelStyle: const TextStyle(
          color: Colors.black
        ),
        errorStyle:  TextStyle(
          color: Colors.red.shade900, // Error message text color
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
          borderSide:  BorderSide(color: Colors.red.shade900),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:  BorderSide(color: Colors.red.shade900),
        ),
      ),
    );
  }



  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter Your Email',
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: _isEmailValid ? Colors.grey.shade400 : Colors.red.shade900),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: _isEmailValid ? Colors.black : Colors.red.shade900),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.red.shade900),
        ),
        errorText: _isEmailValid ? null : 'Please enter a valid email address',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!_isValidEmail(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }





  Widget _buildCountryField() {
    return GestureDetector(
      onTap: () => _showCountrySelectionSheet(),
      child: Container(
        height: 45.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isLocationError && selectedCountry == null ? Colors.red.shade900 : Colors.grey.shade400,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedCountry != null ? selectedCountry! : 'Select Country',
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
    );
  }


  Widget _buildStateField() {
    return GestureDetector(
      onTap: () => _showStateSelectionSheet(),
      child: Container(
        height: 45.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isLocationError && selectedState == null ? Colors.red.shade900  : Colors.grey.shade400,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedState != null ? selectedState! : 'Select State',
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
    );
  }


  Widget _buildCityField() {
    return GestureDetector(
      onTap: () => _showCitySelectionSheet(),
      child: Container(
        height: 45.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isLocationError && selectedCity == null ? Colors.red.shade900  : Colors.grey.shade400,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedCity != null ? selectedCity! : 'Select City',
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
              borderSide: BorderSide(color: Colors.red.shade900 ), // Red border on error
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
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: _isGenderError ? Colors.red.shade900  : Colors.grey.shade400,
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
                  color:  Colors.black,
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


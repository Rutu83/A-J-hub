
// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, depend_on_referenced_packages

import 'dart:convert';

import 'package:allinone_app/main.dart';
import 'package:allinone_app/model/user_data_modal.dart';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:allinone_app/utils/chapter_shimmer.dart';
import 'package:allinone_app/utils/empty_error_state_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var UserId;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _shopeNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  bool _isLoading = false;
  final bool _isdataLoding = true;

  void navigateBack() {
    Navigator.pop(context);
    snackBarMsgShow(context);
  }

  void tostMsgShow() {
    snackBarMsgShow1(context);

  }

  Future<List<UserData>>? future;
  Map<String, dynamic> userData = {};
  Future<Map<String, dynamic>>? futureUserDetail;
  UniqueKey keyForStatus = UniqueKey();

  @override
  void initState() {
    super.initState();
    init();
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    fetchUserData();

  //  fetchProfileData();
    // Fetch user dat
  }






  Future<void> fetchProfileData() async {
    // API URL
    const String url = 'https://ajhub.co.in/api/profile';
    if (kDebugMode) {
      print(appStore.Email);
    }
    if (kDebugMode) {
      print(appStore.Name);
    }
    if (kDebugMode) {
      print(appStore.token);
    }
    // Replace this with your actual token
     String token = appStore.token;

    try {
      // Make the GET request with the token in the headers
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token, // Add the token here
        },
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Decode the response body
        var data = jsonDecode(response.body);
        if (kDebugMode) {
          print(data);
        }
        // Handle the data
      } else {
        // Handle the error
        if (kDebugMode) {
          print('Failed to fetch data: ${response.statusCode}');
        }
        if (kDebugMode) {
          print('Failed to fetch data: ${response.body}');
        }
      }
    } catch (e) {
      // Handle any exceptions
      if (kDebugMode) {
        print('Error occurred: $e');
      }
    }
  }







  void init() async {
    futureUserDetail = getUserDetail();
    if (kDebugMode) {
      print('Hello USer  $futureUserDetail');
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
      }
      if (kDebugMode) {
        print(userDetail);
      }

      setState(() {
        UserId = userDetail['_id'];
        _nameController.text = userDetail['username'] ?? '';
        _emailController.text = userDetail['Dipak Darji'] ?? '';

      });
    } catch (e) {

      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isdataLoding
          ? const Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ))
          : SingleChildScrollView(
          child: SnapHelperWidget<Map<String, dynamic>>(
              initialData: cachedData,
              future: futureUserDetail,
              errorBuilder: (error) {
                return Center(
                  child: NoDataWidget(
                    title: error,
                    imageWidget: const ErrorStateWidget(),
                    retryText: language.reload,
                    onRetry: () {
                      keyForStatus = UniqueKey();
                      appStore.setLoading(true);
                      init();
                      setState(() {});
                    },
                  ),
                );
              },
              loadingWidget: const ChapterShimmer(),
              onSuccess: (data) {
                if (kDebugMode) {
                  print('Get Data $data');
                }
                return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.black,
                                  size: 32,
                                )),
                          ),
                          SizedBox(
                            width: 110.w,
                          ),
                          // ProfilePicture(
                          //   name: '${data['name']}${data['email']}',
                          //   radius: 30,
                          //   fontsize: 16.sp,
                          //   tooltip: true,
                          //   //   img: '${customer.profile}',
                          // ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.012,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Text(
                        language.updateAccountTitle,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            top: 5, right: 18.w, left: 18.w, bottom: 10),
                        child: TextFormField(
                          controller: _nameController,
                          // maxLength: 8,
                          //   obscureText: true,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: const EdgeInsets.all(9),
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.grey,
                            ),
                            // suffixIcon : Icon(Icons.remove_red_eye_outlined),
                            labelText: language.nameLbl,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        ignoring: true,
                        child: InkWell(
                          onTap: () {

                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                top: 5,
                                right: 18.w,
                                left: 18.w,
                                bottom: 10),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.all(9),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Colors.grey,
                                ),
                                labelText: language.email,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.only(
                            top: 0, right: 18.w, left: 18.w, bottom: 8),
                        child: TextFormField(
                          controller: _shopeNameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: const EdgeInsets.all(9),
                            prefixIcon: const Icon(
                              Icons.business,
                              color: Colors.grey,
                            ),
                            labelText: language.signUpShopNameLabel,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),

                      Container(
                        padding: EdgeInsets.only(
                            top: 5, right: 18.w, left: 18.w, bottom: 10),
                        child: TextFormField(
                          controller: _pincodeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: const EdgeInsets.all(9),
                            prefixIcon: const Icon(
                              Icons.numbers_outlined,
                              color: Colors.grey,
                            ),
                            labelText: language.signUpPinCodeLabel,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            top: 5, right: 18.w, left: 18.w, bottom: 10),
                        child: TextFormField(
                          controller: _addressController,
                          keyboardType: TextInputType.streetAddress,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: const EdgeInsets.all(9),
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey,
                            ),
                            labelText: language.address,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.020,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isLoading = true;
                          });
                          //
                          // updateUserData(UserId,
                          //     name: _nameController.text,
                          //     email: _emailController.text,
                          //     number: _phoneController.text,
                          //     shopName: _shopeNameController.text,
                          //     country: _countryController,
                          //     state: _stateController,
                          //     city: _cityController,
                          //     pincode: _pincodeController.text,
                          //     address: _addressController.text,
                          //     onSuccess: navigateBack,
                          //     onSuccesss: () {
                          //       setState(() {
                          //         _isLoading =
                          //         false; // Set loading state to false after success
                          //       });
                          //     },
                          //     onFail: tostMsgShow,
                          //     onFaild: () {
                          //       setState(() {
                          //         _isLoading =
                          //         false; // Set loading state to false after success
                          //       });
                          //     }
                          // );

                          //  String token = '${appStore.token}';

                          // updateUserData(
                          //     UserId,
                          //     name: _nameController.text,
                          //     email: _emailController.text,
                          //     number: _phoneController.text,
                          //     shopName: _shopeNameController.text,
                          //     country: _countryController,
                          //     state: _stateController,
                          //     city: _cityController,
                          //     pincode: _pincodeController.text,
                          //     address: _addressController.text,
                          //     onSuccess: navigateBack);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 60,
                          width: double.infinity,
                          margin: const EdgeInsets.only(
                              right: 36, left: 36, top: 0, bottom: 10),
                          decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                              BorderRadius.all(Radius.circular(12))),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : Text(
                            language.update,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ]);
              })),
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

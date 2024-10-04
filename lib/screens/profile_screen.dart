// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously, non_constant_identifier_names

import 'package:allinone_app/arth_screens/login_screen.dart';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:allinone_app/screens/edit_profile.dart';
import 'package:allinone_app/screens/refer_earn.dart';
import 'package:allinone_app/splash_screen.dart';
import 'package:allinone_app/utils/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var UserId;
  var totalDownline;
  var directDownline;
  var totalIncome;
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
  }

  void init() async {
    futureUserDetail = getUserDetail();
    if (kDebugMode) {
      print('Hello User  $futureUserDetail');
    }
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
        totalDownline.text = userDetail['profile']['direct_team_count'] ?? '';
        directDownline.text = userDetail['profile']['phone_number'] ?? '';
        totalIncome = userDetail['gender'] ?? 'Select Gender';
      });

    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
      setState(() {
// Ensure loading state is false even on error
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        titleSpacing: 7.w,
        title:  Text(
          'Profile',
          style: GoogleFonts.roboto(
            fontSize: 18.0.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(bottom: 56.0),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10,),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36.r,
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                      child: CircleAvatar(
                        radius: 33.r,
                        backgroundImage: const NetworkImage('https://your_image_link.com'), // Replace with user's profile picture
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              totalIncome.toString(),
                              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.red),
                            ),
                            SizedBox(height: 3.h),
                            Text("Total Income", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black54)),
                          ],
                        ),
                        SizedBox(width: 25.w),
                        Column(
                          children: [

                            Text(
                              totalDownline.toString(),
                              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                            SizedBox(height: 3.h),
                            Text("Total Team", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black54)),
                          ],
                        ),
                        SizedBox(width: 25.w),
                        Column(
                          children: [
                            Text(
                              directDownline.toString(),
                              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                            SizedBox(height: 3.h),
                            Text("Direct Joins", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Rank, Team, Joins


              SizedBox(height: 20.h),
              // Wallet Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWalletBox("₹ 10,000", "Current Wallet", Colors.red),
                  _buildWalletBox("₹ 2,500", "Bonus Wallet", Colors.red),
                ],
              ),
              SizedBox(height: 20.h),

              // Menu Options
              _buildMenuOption(Icons.person, "My Profile"),
              _buildMenuOption(Icons.picture_as_pdf, "Plan PDF"),
              _buildMenuOption(Icons.account_balance_outlined, "KYC Details"),
              _buildMenuOption(Icons.receipt_long_rounded, "Transaction Report"),
              _buildMenuOption(Icons.receipt_long_rounded, "Income Report"),
              _buildMenuOption(Icons.receipt_long_rounded, "Refer & Earn"),
              _buildMenuOption(Icons.lock, "Change Password"),
              _buildMenuOption(Icons.login, "Logout"),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build Wallet Box
  Widget _buildWalletBox(String amount, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 19.h, horizontal: 30.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Function to build Menu Option
  Widget _buildMenuOption(IconData icon, String label) {
    return InkWell(
      onTap: () async{
      if (label == "Logout") {
        // Handle logout logic
        var pref = await SharedPreferences.getInstance();

        // Remove specific keys
        await pref.remove(SplashScreenState.keyLogin);
        await pref.remove(TOKEN);
        await pref.remove(NAME);
        await pref.remove(EMAIL);

        // Reset app store data
        await appStore.setToken('', isInitializing: true);
        await appStore.setName('', isInitializing: true);
        await appStore.setEmail('', isInitializing: true);

        // Navigate to login
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else if (label == "My Profile") {
        // Navigate to the profile page
        Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfile()));
      } else if (label == "Refer & Earn") {

        Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferEarn()));
      } else {
        // Handle other options if needed
        if (kDebugMode) {
          print("Other menu option clicked: $label");
        }
      }
      },
      child: Container(
        margin: EdgeInsets.only(top: 10.h),
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.red, size: 22.sp),
            SizedBox(width: 12.w),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_outlined, color: Colors.black54, size: 18.sp),
          ],
        ),
      ),
    );
  }
}

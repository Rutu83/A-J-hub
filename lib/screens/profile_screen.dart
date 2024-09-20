// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:allinone_app/arth_screens/login_screen.dart';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/screens/change_password_screen.dart';
import 'package:allinone_app/screens/edit_profile.dart';
import 'package:allinone_app/splash_screen.dart';
import 'package:allinone_app/utils/configs.dart';
import 'package:allinone_app/utils/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      print(appStore.Email);
      print(appStore.Name);
      print(appStore.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> share() async {
      String title = 'divya has invited you to $APP_NAME';
      String message =
          "Experience the essence of India's tea culture with the Tea Cup App. Whether you're starting your day with a serene cup of tea or exploring bustling streets, our app seamlessly blends tradition with cutting-edge technology."
          "With just a tap, effortlessly manage your tea and water bottle supplies. Our app calculates daily supply needs tailored to each customer, ensuring you're always well-stocked."
          "Stay in control of your business with real-time revenue tracking, empowering you to make informed decisions on the fly."
          "Say goodbye to complex billing procedures. With a simple click, generate monthly bills and deliver them directly to your customers' WhatsApp."
          "Streamline your operations, enhance customer satisfaction, and embrace the perfect fusion of tradition and innovation with the Tea Cup App. Join us on this journey and elevate your tea business to new heights.";
      await FlutterShare.share(
        title: title,
        text: message,
        linkUrl: Playstore_URL,
        chooserTitle: 'Share with buddies',
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              CircleAvatar(
                radius: 33.r,
                backgroundColor: Colors.indigoAccent.withOpacity(0.2),
                child: Icon(Icons.person_outline, size: 60.sp, color: Colors.red),
              ),
              SizedBox(height: 6.h),
              Text(
                appStore.Name,
                style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.h),
              Text(
                appStore.Email,
                style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Colors.black87),
              ),
              SizedBox(height: 10.h),
              _buildOptionRow('My Profile', Icons.person, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfile()));
              }),
              _buildOptionRow('Plan Pdf', Icons.picture_as_pdf),
              _buildOptionRow('Kyc Details', Icons.account_balance_outlined),
              _buildOptionRow('Transaction Report', Icons.receipt_long_rounded),
              _buildOptionRow('Income Report', Icons.receipt_long_rounded),
              _buildOptionRow('Change Password', Icons.lock, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
              }),
              _buildOptionRow('Change Transaction Password', Icons.lock_outline),
              _buildOptionRow('Share', Icons.share, share),
              _buildOptionRow('About Us', Icons.info_outline, _launchURL),

              InkWell(
                onTap: () async {
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
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
                  margin: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      'Log out',
                      style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 25.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow(String title, IconData icon, [VoidCallback? onTap]) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: 10.h),
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 18.sp),
            SizedBox(width: 12.w),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_outlined, color: Colors.black54, size: 18.sp),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL() async {
    const url = 'https://website.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

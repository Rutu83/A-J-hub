// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously

import 'package:allinone_app/arth_screens/login_screen.dart';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:allinone_app/screens/change_password_screen.dart';
import 'package:allinone_app/screens/contact_us.dart';
import 'package:allinone_app/screens/edit_profile.dart';
import 'package:allinone_app/screens/help_support.dart';
import 'package:allinone_app/screens/refer_earn.dart';
import 'package:allinone_app/splash_screen.dart';
import 'package:allinone_app/utils/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userId;
  var totalDownline;
  var directDownline;
  var totalIncome;
  Map<String, dynamic> userData = {};
  Future<Map<String, dynamic>>? futureUserDetail;
  UniqueKey keyForStatus = UniqueKey();
  bool _isLoading = true;
  bool _imageLoadFailed = false;

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
      print('User details fetched: $futureUserDetail');
    }
  }

  void fetchUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> userDetail = await getUserDetail();
      if (kDebugMode) {
        print('User details: $userDetail');
      }

      setState(() {
        userId = userDetail['_id'];
        totalDownline = userDetail['profile']['direct_team_count'] ?? '';
        directDownline = userDetail['profile']['phone_number'] ?? '';
        totalIncome = userDetail['gender'] ?? 'Select Gender';
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user data: $e");
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
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        titleSpacing: 7.w,
        title: Text(
          'Profile',
          style: GoogleFonts.roboto(
            fontSize: 18.0.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      )
          : SingleChildScrollView(
               child: Container(
                 margin: const EdgeInsets.only(bottom: 56.0),
                 padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 10),
                       child: Row(
                         children: [
                           CircleAvatar(
                             radius: 36.r,
                             backgroundColor: Colors.redAccent.withOpacity(0.8),
                             child: CircleAvatar(
                               radius: 33.r,
                               backgroundImage: _imageLoadFailed
                                   ? const AssetImage('assets/images/placeholder.jpg')
                                   : const NetworkImage('https://www.google.co.in/') as ImageProvider,
                               onBackgroundImageError: (_, __) {
                                 setState(() {
                                   _imageLoadFailed = true;
                                 });
                               },
                             ),
                           ),
                           const Spacer(),
                           _buildInfoColumn(totalIncome, "Total Income", Colors.red),
                           SizedBox(width: 10.w),
                           _buildInfoColumn(totalDownline, "Total Team", Colors.black),
                           SizedBox(width: 10.w),
                           _buildInfoColumn(directDownline, "Direct Joins", Colors.black),
                         ],
                       ),
                      ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildWalletBox("₹ 10,000", "Current Wallet", Colors.red),
                        _buildWalletBox("₹ 2,500", "Bonus Wallet", Colors.red),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    _buildMenuOptions(),
                    SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(dynamic value, String label, Color color) {
    return Column(
      children: [
        Text(
          (value ?? 0).toString(),
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

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
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,

              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildMenuOptions() {
    return Column(
      children: [
        _buildMenuOption(Icons.person_outline, "My Profile"),
        _buildMenuOption(Icons.picture_as_pdf, "Plan PDF"),
        _buildMenuOption(Icons.contact_mail_outlined, "Contact Us"),
        _buildMenuOption(Icons.info_outline, "Terms of use", 'https://www.ajhub.co.in/term-condition'),
        _buildMenuOption(Icons.account_balance_outlined, "KYC Details",'https://www.google.co.in/'),
        _buildMenuOption(Icons.privacy_tip_outlined, "Privacy Policy", 'https://www.ajhub.co.in/policy'),
        _buildMenuOption(Icons.help_center_outlined, "Help & Support"),
        _buildMenuOption(Icons.receipt_long_rounded, "Our Product & Service",'https://www.google.co.in/'),
        _buildMenuOption(Icons.local_police_outlined, "Refund & Policy",'https://www.ajhub.co.in/refund-policy'),
        _buildMenuOption(Icons.money, "Refer & Earn"),
        _buildMenuOption(Icons.delete_outline, "Delete Account"),
        _buildMenuOption(Icons.lock_outline, "Change Password"),
        _buildMenuOption(Icons.login, "Logout"),
      ],
    );
  }

  Widget _buildMenuOption(IconData icon, String label, [String? url]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          if (label == "Logout") {
            var pref = await SharedPreferences.getInstance();
            await pref.remove(SplashScreenState.keyLogin);
            await pref.remove(TOKEN);
            await pref.remove(NAME);
            await pref.remove(EMAIL);
            await appStore.setToken('', isInitializing: true);
            await appStore.setName('', isInitializing: true);
            await appStore.setEmail('', isInitializing: true);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          } else if (label == "Delete Account") {
            _showDeleteAccountDialog();
          } else if (url != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WebViewScreen(url: url)),
            );
          } else if (label == "My Profile") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfile()),
            );
          } else if (label == "Refer & Earn") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReferEarn()),
            );
          } else if (label == "Contact Us") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUs()),
            );
          } else if (label == "Help & Support") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpSupport()),
            );
          }else if (label == "Change Password") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
            );
          } else {
            if (kDebugMode) {
              print("Other menu option clicked: $label");
            }
          }
        },
        child: Container(
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
      ),
    );
  }


  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}





class WebViewScreen extends StatelessWidget {
  final String url;

  const WebViewScreen({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar or progress indicator
          },
          onPageStarted: (String url) {
            // Show loader when page starts loading
          },
          onPageFinished: (String url) {
            // Hide loader when page finishes loading
          },
          onHttpError: (HttpResponseError error) {
            // Handle HTTP errors
          },
          onWebResourceError: (WebResourceError error) {
            // Handle resource errors
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent; // Prevent navigation to YouTube URLs
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));


    return Scaffold(

      body: WebViewWidget(controller: controller),
    );
  }
}


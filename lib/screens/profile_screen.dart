// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously
import 'dart:async';
import 'dart:io';

import 'package:ajhub_app/arth_screens/login_screen.dart';
import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/model/business_mode.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/business_list.dart';
import 'package:ajhub_app/screens/change_password_screen.dart';
import 'package:ajhub_app/screens/edit_profile.dart';
import 'package:ajhub_app/screens/faq_page.dart';
import 'package:ajhub_app/screens/feedback_screen.dart';
import 'package:ajhub_app/screens/image_download_screen.dart';
import 'package:ajhub_app/screens/palnner/plan_list_screen.dart';
import 'package:ajhub_app/screens/product_and_service.dart';
import 'package:ajhub_app/screens/refer_earn.dart';
import 'package:ajhub_app/screens/referral_user.dart';
import 'package:ajhub_app/screens/payment/airpay_payment_screen.dart';
import 'package:ajhub_app/screens/payment/premium_plans_screen.dart';
import 'package:ajhub_app/screens/yourdocument_locker.dart';
import 'package:ajhub_app/splash_screen.dart';
import 'package:ajhub_app/utils/constant.dart';
import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  String status = '';
  var userId;
  var username;
  var email;
  Map<String, dynamic> userData = {};
  Future<Map<String, dynamic>>? futureUserDetail;
  UniqueKey keyForStatus = UniqueKey();
  bool _isLoading = true;
  Future<List<BusinessModal>>? futureBusiness;
  BusinessModal? businessData;
  int directTeamCount = 0;

  // --- NEW: State variable for the referral points wallet ---
  int referPoints = 0;

  bool hasError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    init();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    fetchUserData();
    futureBusiness = fetchBusinessData();
  }

  Future<List<BusinessModal>> fetchBusinessData() async {
    try {
      final data = await getBusinessData(businessmodal: []);
      if (data.isNotEmpty) {
        businessData = data.first;
      }
      return data;
    } catch (e) {
      throw Exception('Failed to load business data: $e');
    }
  }

  void init() async {
    futureUserDetail = getUserDetail();
  }

  void fetchUserData() async {
    try {
      setState(() {
        _isLoading = true;
        hasError = false;
        errorMessage = "";
      });

      Map<String, dynamic> userDetail = await getUserDetail();

      setState(() {
        userId = userDetail['userId']?.toString() ?? "N/A";
        status = userDetail['status']?.toString() ?? "Unknown";
        username = userDetail['username'] ?? '';
        email = userDetail['email'] ?? '';
        directTeamCount = userDetail['direct_team_count'] ?? 0;

        // --- UPDATED: Calculate referral points (1 referral = 5 points) ---
        referPoints = directTeamCount * 5;

        _isLoading = false;
      });
    } on SocketException {
      setState(() {
        _isLoading = false;
        hasError = true;
        errorMessage = "No internet connection. Please check your network.";
      });
    } on TimeoutException {
      setState(() {
        _isLoading = false;
        hasError = true;
        errorMessage = "Network timeout. Please try again.";
      });
    } on HttpException {
      setState(() {
        _isLoading = false;
        hasError = true;
        errorMessage = "Couldn't connect to the server. Try again later.";
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
      setState(() {
        _isLoading = false;
        hasError = true;
        errorMessage = "An unexpected error occurred: $e";
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure KeepAlive logic runs
    if (hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Lottie.asset(
                    'assets/animation/no_internet_2_lottie.json',
                    width: 350,
                    height: 350,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Oops! Something went wrong.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please check your connection and try again.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      hasError = false;
                      _isLoading = true;
                    });
                    fetchUserData();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text("Retry",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        titleSpacing: 7.w,
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 20.0.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.red,
          size: 20.sp,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15.r),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15.h),
              _isLoading ? _buildHeaderShimmer() : _buildProfileHeader(),
              SizedBox(height: 25.h),
              // --- UPDATED: Using the new sectioned menu ---
              _buildMenuOptions(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatReferrals(String value, String label) {
    return InkWell(
      onTap: () {
        final referrals = businessData?.business?.levelDownline;
        if (referrals != null && referrals.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RefferalUserList(
                userData: businessData!.business?.levelDownline,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please Wait Data Loaded...')),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade500, Colors.red.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 32.r,
                  backgroundImage:
                      const AssetImage('assets/images/app_logo.png'),
                  backgroundColor: Colors.red.shade50,
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      email.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Divider(color: Colors.white.withOpacity(0.5)),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatReferrals(
                  directTeamCount.toString(), 'Total\nReferrals'),
              _buildStatColumn(referPoints.toString(), 'Referral\nPoints'),
              _buildStatColumn('₹${businessData?.business?.directIncome ?? 0}',
                  'Referral\nIncome'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }

  // --- NEW: Helper widget to create section titles ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h, top: 10.h),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  // --- REFACTORED: Menu options are now grouped by category ---
  Widget _buildMenuOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Account"),
        _buildMenuOption(CupertinoIcons.person_alt_circle, "My Profile"),
        _buildMenuOption(Icons.business, "My Business"),
        _buildMenuOption(CupertinoIcons.lock_rotation, "Change Password"),
        SizedBox(height: 15.h),
        _buildSectionTitle("App Features"),
        _buildMenuOption(Icons.document_scanner, "Your Document Locker"),
        _buildMenuOption(CupertinoIcons.list_bullet, "Plan A Day"),
        _buildMenuOption(
            CupertinoIcons.arrow_down_to_line, "Downloaded Images"),
        _buildMenuOption(Icons.share, "Refer & Earn"),
        SizedBox(height: 15.h),
        _buildSectionTitle("Support & Community"),
        _buildMenuOption(CupertinoIcons.question_circle, "Help & Support"),
        _buildMenuOption(Icons.question_answer, "FAQs"),
        _buildMenuOption(CupertinoIcons.smiley, "Feedback"),
        _buildMenuOption(Icons.groups, "Join Our Community"),
        _buildMenuOption(CupertinoIcons.bag, "Biz Boost"),
        _buildMenuOption(Icons.credit_card, "Test Payment (Airpay)"),
        _buildMenuOption(CupertinoIcons.doc_plaintext, "Terms of Use",
            'https://www.ajhub.co.in/term-condition'),
        _buildMenuOption(Icons.privacy_tip, "Privacy Policy",
            'https://www.ajhub.co.in/policy'),
        SizedBox(height: 15.h),
        _buildSectionTitle("Actions"),
        _buildMenuOption(
          Icons.logout,
          "Logout",
          null,
        ),
        _buildMenuOption(
          Icons.delete_forever,
          "Delete Account",
          null,
        ),
      ],
    );
  }

  void openWhatsAppGroup(BuildContext context) async {
    const groupLink = "https://chat.whatsapp.com/K50pflHRu6EB1IXSpKOrbl";
    final uri = Uri.parse(groupLink);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Could not open WhatsApp group. Please ensure the app is installed.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  void openWhatsApp(BuildContext context) async {
    const phone = "917863045542";
    final message = Uri.encodeComponent('');
    final whatsappUrl = "https://wa.me/$phone?text=$message";
    final uri = Uri.parse(whatsappUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Could not open WhatsApp. Please ensure the app is installed.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  // --- UPDATED: `_buildMenuOption` now accepts an `isDestructive` flag ---
  Widget _buildMenuOption(IconData icon, String label,
      [String? url, bool isDestructive = false]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          if (label == "Logout") {
            _showLogOutAccountDialog();
          } else if (label == "Delete Account") {
            _showDeleteAccountDialog();
          } else if (label == "Join Our Community") {
            openWhatsAppGroup(context);
          } else if (label == "Help & Support") {
            openWhatsApp(context);
          } else if (label == "FAQs") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FAQPage()),
            );
          } else if (url != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WebViewScreen(url: url)),
            );
          } else if (label == "Plan A Day") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlanListScreen()),
            );
          } else if (label == "My Profile") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfile()),
            );
          } else if (label == "My Business") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BusinessList()),
            );
          } else if (label == "Your Document Locker") {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DocumentLockerScreen()),
            );
          } else if (label == "Change Password") {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage()),
            );
          } else if (label == "Downloaded Images") {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DownloadedImagesPage()),
            );
          } else if (label == "Refer & Earn") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReferEarn()),
            );
          } else if (label == "Feedback") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FeedbackScreen()),
            );
          } else if (label == "Biz Boost") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OurProductAndService(),
              ),
            );
          } else if (label == "Test Payment (Airpay)") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PremiumPlansScreen(),
              ),
            );
          } else {
            if (kDebugMode) {
              print("Other menu option clicked: $label");
            }
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 15.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color:
                      isDestructive ? Colors.red.shade50 : Colors.red.shade50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color:
                      isDestructive ? Colors.red.shade700 : Colors.red.shade700,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? Colors.red.shade700 : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_outlined,
                color:
                    isDestructive ? Colors.red.shade700 : Colors.grey.shade500,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogOutAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                var pref = await SharedPreferences.getInstance();
                await pref.remove(SplashScreenState.keyLogin);
                await pref.remove(TOKEN);
                await pref.remove(NAME);
                await pref.remove(EMAIL);
                await pref.remove('active_business');
                await appStore.setToken('', isInitializing: true);
                await appStore.setName('', isInitializing: true);
                await appStore.setEmail('', isInitializing: true);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Log out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // You would add your account deletion API call here.
                // For now, it just closes the dialog.
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
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(
          title:
              Text(url.split('/').last.replaceAll('-', ' '))), // Simple AppBar
      body: WebViewWidget(controller: controller),
    );
  }
}

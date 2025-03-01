// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously
import 'package:ajhub_app/arth_screens/login_screen.dart';
import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/model/business_mode.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/active_user_screen.dart';
import 'package:ajhub_app/screens/active_user_screen2.dart';
import 'package:ajhub_app/screens/business_list.dart';
import 'package:ajhub_app/screens/change_password_screen.dart';
import 'package:ajhub_app/screens/contact_us.dart';
import 'package:ajhub_app/screens/edit_profile.dart';
import 'package:ajhub_app/screens/faq_page.dart';
import 'package:ajhub_app/screens/feedback_screen.dart';
import 'package:ajhub_app/screens/image_download_screen.dart';
import 'package:ajhub_app/screens/kyc_screen.dart';
import 'package:ajhub_app/screens/product_and_service.dart';
import 'package:ajhub_app/screens/refer_earn.dart';
import 'package:ajhub_app/screens/team_member_list.dart';
import 'package:ajhub_app/screens/transaction_history.dart';
import 'package:ajhub_app/splash_screen.dart';
import 'package:ajhub_app/utils/constant.dart';
import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String status = '';
  var userId;
  var totalDownline;
  var directDownline;
  var totalIncome;
  var GreenWallet;
  var TDSIncome;
  Map<String, dynamic> userData = {};
  Future<Map<String, dynamic>>? futureUserDetail;
  UniqueKey keyForStatus = UniqueKey();
  bool _isLoading = true;
  Future<List<BusinessModal>>? futureBusiness;
  BusinessModal? businessData;


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
      });

      Map<String, dynamic> userDetail = await getUserDetail();



      setState(() {
        userId = userDetail['_id'];
        status = userDetail['status'].toString();
        totalDownline = userDetail['total_downline_count'] ?? '0';
        directDownline = userDetail['direct_team_count'] ?? '0';
        String incomeString = userDetail['total_income'] ?? '0';
         totalIncome = (double.tryParse(incomeString) ?? 0.0).toInt();
         int  GreenWallet1 = (totalIncome * 0.10).toInt();
        GreenWallet =totalIncome - GreenWallet1;
        TDSIncome = (totalIncome * 0.10).toInt();
        //   TDSIncome = GreenWallet - TDSIncome1;

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

      body: _isLoading
          ? _buildSkeletonLoader()
          : SingleChildScrollView(
               child: Container(

                 padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 1.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                 Container(
                 padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
                 decoration: BoxDecoration(
                   //color: Colors.grey.shade50,
                   borderRadius: BorderRadius.circular(12.r),
                   // boxShadow: [
                   //   BoxShadow(
                   //     color: Colors.grey.withOpacity(0.3),
                   //     blurRadius: 8,
                   //     offset: const Offset(0, 4),
                   //   ),
                   // ],
                 ),
                 child: Row(
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     Container(
                       width: 80.w,
                       height: 80.w,
                       decoration: BoxDecoration(
                         color: Colors.white,
                         shape: BoxShape.circle,
                         border: Border.all(
                           color: Colors.red,
                           width: 2.0,
                         ),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.grey.withOpacity(0.3),
                             blurRadius: 5,
                             offset: const Offset(0, 2),
                           ),
                         ],
                       ),
                       child: CircleAvatar(
                         radius: 28.w,
                         backgroundImage: const AssetImage('assets/images/app_logo.png'),
                         backgroundColor: Colors.red.shade50,
                       ),
                     ),
                     SizedBox(width: 15.w),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceAround,
                             children: [
                               _buildInfoColumn('₹ ${totalIncome ?? 0}', "Gross Income", Colors.black),
                               //   _buildInfoColumn(totalDownline, "Total Team", Colors.black),
                               _buildInfoColumn(directDownline, "Total Refer", Colors.black),
                             ],
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),


          SizedBox(height: 20.h),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         _buildWalletBox(
                           "₹ ${GreenWallet ?? 0}",
                           "Net Income",
                           Colors.green,
                         ),
                         _buildWalletBox(
                           "₹ ${TDSIncome ?? 0}",
                           "TDS (Tax)",
                           Colors.red,
                         ),
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


  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        children: [
          Row(
            children: [
              Container(
                width: 80.r,
                height: 80.r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 150.w, height: 16.h, color: Colors.white),
                  SizedBox(height: 8.h),
                  Container(width: 100.w, height: 12.h, color: Colors.white),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(height: 60.h, margin: const EdgeInsets.only(bottom: 12), color: Colors.white),
          Container(height: 60.h, margin: const EdgeInsets.only(bottom: 12), color: Colors.white),
          Container(height: 60.h, margin: const EdgeInsets.only(bottom: 12), color: Colors.white),
          Container(height: 60.h, margin: const EdgeInsets.only(bottom: 12), color: Colors.white),
          Container(height: 60.h, margin: const EdgeInsets.only(bottom: 12), color: Colors.white),
          Container(height: 60.h, margin: const EdgeInsets.only(bottom: 12), color: Colors.white),

        ],
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
      width: 150.w,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color == Colors.red ? Colors.red.shade400 : Colors.grey.shade500,
            color == Colors.red ? Colors.red.shade600 : Colors.grey.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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

        _buildMenuOption(CupertinoIcons.person_alt_circle, "My Profile"),
        _buildMenuOption(Icons.business, "My Business"),
        _buildMenuOption(Icons.groups, "Join Our Community"),
        //    _buildMenuOption(CupertinoIcons.person_2_alt, "Team List"),
        _buildMenuOption(Icons.verified_user, "Activation"),
        _buildMenuOption(Icons.card_membership, "Activate Your Membership"),
        _buildMenuOption(CupertinoIcons.bag, "Our Product & Services"),
        _buildMenuOption(CupertinoIcons.arrow_right_arrow_left_circle, "Transaction History"),
        _buildMenuOption(CupertinoIcons.arrow_down_to_line, "Downloaded Images"),
        _buildMenuOption(CupertinoIcons.smiley, "Feedback"),
        _buildMenuOption(Icons.question_answer, "FAQs"),
        _buildMenuOption(CupertinoIcons.doc_plaintext, "Terms of Use", 'https://www.ajhub.co.in/term-condition'), // Article icon for terms
        _buildMenuOption(Icons.account_balance_wallet, "KYC Details"),
        _buildMenuOption(Icons.privacy_tip, "Privacy Policy", 'https://www.ajhub.co.in/policy'),
        _buildMenuOption(CupertinoIcons.question_circle, "Help & Support"),
        _buildMenuOption(CupertinoIcons.lock_shield, "Refund & Policy", 'https://www.ajhub.co.in/refund-policy'), // Policy icon
        _buildMenuOption(Icons.share, "Refer & Earn"),
        _buildMenuOption(CupertinoIcons.lock_rotation, "Change Password"),
        _buildMenuOption(Icons.logout, "Logout"),
        _buildMenuOption(Icons.delete_forever, "Delete Account"),
      ],
    );
  }


  void openWhatsAppGroup(BuildContext context) async {
    const groupLink = "https://chat.whatsapp.com/K50pflHRu6EB1IXSpKOrbl"; // Your WhatsApp group link

    try {
      if (await canLaunch(groupLink)) {
        await launch(groupLink, forceSafariVC: false, forceWebView: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open WhatsApp group. Please ensure the app is installed.")),
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

    try {
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl, forceSafariVC: false, forceWebView: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open WhatsApp. Please ensure the app is installed.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  Widget _buildMenuOption(IconData icon, String label, [String? url]) {
    bool isButtonDisabled =  label == "My Business" && status != "active";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isButtonDisabled
            ? () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Membership Required"),
                content: const Text(
                 "You can add your business details after activating your membership package.",
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );

        }
            : () async {
          if (label == "Join Our Community") {
            openWhatsAppGroup(context);
          } else if (label == "FAQs") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FAQPage()),
            );
          } else if (label == "Logout") {
            _showLogOutAccountDialog();
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
          } else if (label == "Transaction History") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TransactionHistory()),
            );
          } else if (label == "Team List") {
            if (businessData != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TeamMemberList(userData: businessData!.business?.levelDownline),
                ),
              );
            }
          } else if (label == "Activation") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ActiveUserPage(),
              ),
            );
          } else if (label == "Our Product & Services") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OurProductAndService(),
              ),
            );
          } else if (label == "Activate Your Membership") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ActivateMembershipPage(),
              ),
            );
          } else if (label == "Feedback") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FeedbackScreen()),
            );
          } else if (label == "My Business") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BusinessList()),
            );
          } else if (label == "Downloaded Images") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DownloadedImagesPage()),
            );
          } else if (label == "Refer & Earn") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReferEarn()),
            );
            // if (status == "active") {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => const ReferEarn()),
            //   );
            // } else {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(
            //       content: Text("This feature is disabled because your status is not active."),
            //     ),
            //   );
            // }
          } else if (label == "Contact Us") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUs()),
            );
          } else if (label == "Help & Support") {
            openWhatsApp(context);
          } else if (label == "Change Password") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
            );
          } else if (label == "KYC Details") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KycScreen()),
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
            color: isButtonDisabled ? Colors.grey.shade200 : Colors.white,
            border: Border.all(
              color: isButtonDisabled ? Colors.grey.shade400 : Colors.grey.shade300,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isButtonDisabled
                ? []
                : [
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
                  color: isButtonDisabled ? Colors.grey.shade100 : Colors.red.shade50,
                  shape: BoxShape.circle,
                  boxShadow: isButtonDisabled
                      ? []
                      : [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isButtonDisabled ? Colors.grey.shade600 : Colors.red.shade700,
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
                    color: isButtonDisabled ? Colors.grey.shade600 : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_outlined,
                color: isButtonDisabled ? Colors.grey.shade600 : Colors.grey.shade500,
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

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
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
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
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

      body: WebViewWidget(controller: controller),
    );
  }
}


// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously

import 'package:allinone_app/arth_screens/login_screen.dart';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/model/business_mode.dart';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:allinone_app/screens/active_user_screen.dart';
import 'package:allinone_app/screens/business_list.dart';
import 'package:allinone_app/screens/change_password_screen.dart';
import 'package:allinone_app/screens/contact_us.dart';
import 'package:allinone_app/screens/edit_profile.dart';
import 'package:allinone_app/screens/faq_page.dart';
import 'package:allinone_app/screens/feedback_screen.dart';
import 'package:allinone_app/screens/image_download_screen.dart';
import 'package:allinone_app/screens/kyc_screen.dart';
import 'package:allinone_app/screens/refer_earn.dart';
import 'package:allinone_app/screens/team_member_list.dart';
import 'package:allinone_app/screens/transaction_history.dart';
import 'package:allinone_app/splash_screen.dart';
import 'package:allinone_app/utils/constant.dart';
import 'package:allinone_app/utils/shimmer/shimmer.dart';
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
  bool _imageLoadFailed = false;
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
        businessData = data.first; // Store the first item
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

      print('/////////////////////////$userDetail');

      setState(() {
        userId = userDetail['_id'];
        totalDownline = userDetail['total_downline_count'] ?? '0';
        directDownline = userDetail['direct_team_count'] ?? '0';

        // Check if total_income is a String and convert it to int
        String incomeString = userDetail['total_income'] ?? '0';
        // Assuming totalIncome is already calculated as an integer:
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
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        titleSpacing: 7.w,
        centerTitle: true,
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
          ? _buildSkeletonLoader()
          : SingleChildScrollView(
               child: Container(
                 margin: const EdgeInsets.only(bottom: 0.0),
                 padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 10),
                       child: Row(
                         children: [
                           Container(
                             width: 72.r, // Set this to radius * 2 + border width to account for the border
                             height: 72.r,
                             decoration: BoxDecoration(
                               color: Colors.white, // Background color of the border
                               shape: BoxShape.circle,
                               border: Border.all(
                                 color: Colors.red, // Border color
                                 width: 3.0, // Border width
                               ),
                             ),
                             child: CircleAvatar(
                               radius: 33.r,
                               backgroundImage: _imageLoadFailed
                                   ? const AssetImage('assets/images/aj1.jpg') as ImageProvider
                                   : const NetworkImage('https://www.google.co.in/'),
                               onBackgroundImageError: (_, __) {
                                 if (!_imageLoadFailed) {
                                   _imageLoadFailed = true;
                                 }
                               },

                             ),
                           ),

                           const Spacer(),
                           _buildInfoColumn('₹ ${totalIncome ?? 0}', "Total Income", Colors.black),
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
                        _buildWalletBox(
                          "₹ ${GreenWallet ?? 0}", // Show 0 if GreenWallet is null
                          "Green Wallet",
                          Colors.red,
                        ),

                        _buildWalletBox(
                          "₹ ${TDSIncome ?? 0}", // Show 0 if TDSIncome is null
                          "TDS(Tax)",
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
                width: 72.r,
                height: 72.r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  Container(
                    width: 50.w,
                    height: 16.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    width: 70.w,
                    height: 12.h,
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(width: 4.w),
              Column(
                children: [
                  Container(
                    width: 70.w,
                    height: 16.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    width: 70.w,
                    height: 12.h,
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(width: 4.w),
              Column(
                children: [
                  Container(
                    width: 70.w,
                    height: 16.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    width: 70.w,
                    height: 12.h,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 120.w,
                height: 60.h,
                color: Colors.white,
              ),
              Container(
                width: 120.w,
                height: 60.h,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Column(
            children: List.generate(8, (index) {
              return Container(
                height: 50.h,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              );
            }),
          ),
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
        _buildMenuOption(Icons.groups, "Join Our Community"),
        _buildMenuOption(Icons.person_outline, "My Profile"),
        _buildMenuOption(Icons.business_center_outlined, "My Business"),
        _buildMenuOption(Icons.library_books_outlined, "Team List"),
        _buildMenuOption(Icons.supervised_user_circle_outlined, "Activation"),
        _buildMenuOption(Icons.transfer_within_a_station_outlined, "Transaction History"),
        _buildMenuOption(Icons.image_outlined, "Downloaded Images"),
        _buildMenuOption(Icons.insert_emoticon_sharp, "FeedBack"),
        _buildMenuOption(Icons.question_answer_outlined, "FAQs"),
        _buildMenuOption(Icons.info_outline, "Terms of use", 'https://www.ajhub.co.in/term-condition'),
        _buildMenuOption(Icons.account_balance_outlined, "KYC Details"),
        _buildMenuOption(Icons.privacy_tip_outlined, "Privacy Policy", 'https://www.ajhub.co.in/policy'),
        _buildMenuOption(Icons.help_center_outlined, "Help & Support"),
        // _buildMenuOption(Icons.receipt_long_rounded, "Our Product & Service",'https://www.google.co.in/'),
        _buildMenuOption(Icons.local_police_outlined, "Refund & Policy",'https://www.ajhub.co.in/refund-policy'),
        _buildMenuOption(Icons.money, "Refer & Earn"),
        _buildMenuOption(Icons.lock_outline, "Change Password"),
        _buildMenuOption(Icons.login, "Logout"),
        _buildMenuOption(Icons.delete_outline, "Delete Account"),
      ],
    );
  }

  void openWhatsApp(BuildContext context) async {
    const phone = "919662545518"; // Correct format with country code
    final message = Uri.encodeComponent('');
    final whatsappUrl = "https://wa.me/$phone?text=$message";

    try {
      // Check if the URL can be launched
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl, forceSafariVC: false, forceWebView: false);
      } else {
        // If WhatsApp is not installed or URL cannot be launched
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open WhatsApp. Please ensure the app is installed.")),
        );
      }
    } catch (e) {
      // Catch any errors and display them
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }



  Widget _buildMenuOption(IconData icon, String label, [String? url]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {

          if (label == "Join Our Community") {
            openWhatsApp(context);
          }else if (label == "FAQs") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FAQPage()),
            );
          }
          else if (label == "Logout") {
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
          } else if (label == "Transaction History") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  TransactionHistory()),
            );
          }else if (label == "Team List") {
            if (businessData != null) {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamMemberList(userData: businessData!.business?.levelDownline),
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

          }else if (label == "FeedBack") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>   const FeedbackScreen()),
            );
          }  else if (label == "My Business") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BusinessList()),
            );
          }   else if (label == "Downloaded Images") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DownloadedImagesPage()),
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
            openWhatsApp(context);
          }
          else if (label == "Change Password") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
            );
          }else if (label == "KYC Details") {
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


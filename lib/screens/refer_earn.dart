import 'dart:async';
import 'dart:io';

import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/active_user_screen.dart';
import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferEarn extends StatefulWidget {
  const ReferEarn({super.key});

  @override
  State<ReferEarn> createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> {
  bool _isLoading = true;
  String referralCode = "Loading...";
  bool isMembershipActive = false;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (kDebugMode) {
        print("Fetching user data...");
      }

      Map<String, dynamic> userDetail = await getUserDetail();
      if (kDebugMode) {
        print("Fetched user details: $userDetail");
      }

      // Set status and referral code based on user data
      String status = userDetail['status'] ?? '';  // Default to empty string if status is null
      referralCode = userDetail['referral_code'] ?? 'Unavailable';  // Set referral code

      // Check if the status is active
      if (status == 'active') {
        // Only show referral code if status is active
        setState(() {
          isMembershipActive = true;   // Set to true if status is active
        });
      } else {
        // If status is inactive, set membership to inactive
        setState(() {
          isMembershipActive = false;  // Set to false if status is inactive
        });
      }

      if (kDebugMode) {
        print("Referral Code: $referralCode");
      }

      setState(() {
        _isLoading = false;
      });

    } on SocketException catch (_) {
      setState(() {
        _isLoading = false;
        hasError = true;
        errorMessage = "No internet connection. Please check your network.";
      });
    } on HttpException catch (_) {
      setState(() {
        _isLoading = false;
        hasError = true;
        errorMessage = "Couldn't connect to the server. Try again later.";
      });
    } on TimeoutException catch (_) {
      setState(() {
        _isLoading = false;
        hasError = true;
        errorMessage = "Network timeout. Please try again.";
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        hasError = true;
        errorMessage = "An unexpected error occurred: $e";
      });
    }
  }





  Future<void> _shareOnWhatsApp(String referralCode) async {
    final String message = '''
*Join AJHub today and unlock exciting benefits!* 🚀

Greetings! 🎉 I have become a primary member of AJHub. You too can join and start earning ₹200 for every successful Promote Sign up using my referral code: $referralCode 💸 Build your Circle, grow your network, and unlock even more earning potential! 📈

Start Promoting today and maximize your income! 💰

*Referral Code*: $referralCode 🔑
''';

    final String encodedMessage = Uri.encodeComponent(message);
    final String url = 'https://wa.me/?text=$encodedMessage';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open WhatsApp';
    }
  }

  void _showReferralDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Activate Membership"),
          content: const Text(
            "You can get referral benefits after activating your membership.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Activate your Membership"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActiveUserPage()),
                );
              },
            ),
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

  @override
  Widget build(BuildContext context) {

    if (hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20), // Add padding to the sides
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Network Error Animation with border
                AnimatedOpacity(
                  opacity: hasError ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: 300, // Adjust the width for better responsiveness
                    height: 300, // Adjust the height for better responsiveness
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Colors.red, // Border color
                    //     width: 3, // Border width
                    //   ),
                    //   borderRadius: BorderRadius.circular(12), // Rounded corners
                    // ),
                    child: Lottie.asset(
                      'assets/animation/no_internet_2_lottie.json',
                      width: 350,
                      height: 350,
                    ),
                  ),
                ),

                const SizedBox(height: 30), // Increase spacing

                // Title Text
                const Text(
                  'Oops! Something went wrong.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Slightly darkened text for better contrast
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle Text
                const Text(
                  'Please check your connection and try again.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center, // Center align the text
                ),

                const SizedBox(height: 30), // Increased space between text and button

                // Retry Button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      hasError = false;
                      _isLoading = true;
                    });
                    fetchUserData();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text("Retry", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 18, // Slightly larger font size for better readability
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Refer & Earn',
          style: GoogleFonts.poppins(
            fontSize: 22, // Adjusted font size
            fontWeight: FontWeight.w700, // Bold weight for a more prominent title
            color: Colors.red, // Title text color
            letterSpacing: 1.2, // Optional: Adds spacing between letters
            fontStyle: FontStyle.normal, // Optional: Use 'italic' for italicized text
          ),
        ),
        backgroundColor: Colors.white, // White background for the AppBar
        centerTitle: true, // Center the title
        iconTheme: const IconThemeData(color: Colors.red), // Set icon color to red
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.red,
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImage('assets/images/refer_earn.png'),
            _buildCopyField(),
            _buildButtonRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: _isLoading
          ? Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: double.infinity,
          height: 150.h,
          color: Colors.white,
        ),
      )
          : ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  Widget _buildCopyField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        dashPattern: const [6, 3],
        color: Colors.red,  // Classic red dotted border
        strokeWidth: 1.5,  // Slightly thinner border for a more delicate look
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,  // White background for contrast and a clean look
            borderRadius: BorderRadius.circular(12),  // Smooth rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Your Referral Code: $referralCode',
                  style: TextStyle(
                    fontSize: 16.sp,  // Responsive font size
                    fontWeight: FontWeight.w600,  // Bold but not too heavy
                    color: Colors.black,  // Black text for elegance and readability
                    fontFamily: 'Poppins',  // A modern, elegant font (optional)
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: referralCode)).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Referral code copied to clipboard!',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        backgroundColor: Colors.green.shade700,  // Green feedback message
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.copy, color: Colors.red),  // Classic red copy icon
                tooltip: 'Copy Referral Code',
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildButtonRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          // Refer Now Button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (!isMembershipActive) {
                  _showReferralDialog();
                } else {
                  _shareOnWhatsApp(referralCode);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                shadowColor: Colors.red.withOpacity(0.4),
              ),
              child: Text(
                'Refer Now',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // WhatsApp Button
          ElevatedButton(
            onPressed: () {
              if (!isMembershipActive) {
                _showReferralDialog();
              } else {
                _shareOnWhatsApp(referralCode);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.4),  // Applying opacity to grey border
                  width: 1.5,  // Width of the border
                ),
              ),
              elevation: 3,
              shadowColor: Colors.grey.withOpacity(0.2),
            ),
            child: Image.asset(
              'assets/icons/whatsapp.png', // Add your WhatsApp icon here
              width: 36,
              height: 36,
            ),
          )
        ],
      ),
    );
  }
}

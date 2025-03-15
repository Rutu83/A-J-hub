import 'dart:async';
import 'dart:io';

import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/active_user_screen2.dart';
import 'package:ajhub_app/screens/product_and_service.dart';
import 'package:ajhub_app/screens/refer_earn.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ajhub_app/screens/business_screen.dart';
import 'package:ajhub_app/screens/home_screen.dart';
import 'package:ajhub_app/screens/profile_screen.dart';
import 'package:lottie/lottie.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  String referralCode = "Loading...";
  bool isMembershipActive = false;
  bool hasError = false;
  String errorMessage = '';




  @override
  void initState() {
    super.initState();

    fetchUserData();

  }


  void fetchUserData() async {
    try {
      setState(() {
        hasError = false;
        errorMessage = "";
      });

      Map<String, dynamic> userDetail = await getUserDetail();

      if (kDebugMode) {
        print('...........................................................');
        print("$userDetail?????????????????/");
      }

      // Extract status from user details
      String status = userDetail['status'] ?? '';

      if (status == 'inactive') {
        // If user status is 'inactive', show activation dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showActivationDialog();
        });
      } else {
        if (kDebugMode) {
          print('////////////////////////////////$status');
        }
      }

      // You can store other user details here if needed...

      setState(() {
      });

    } on SocketException catch (_) {
      setState(() {
        hasError = true;
        errorMessage = "No internet connection. Please check your network.";
      });
    } on HttpException catch (_) {
      setState(() {
        hasError = true;
        errorMessage = "Couldn't connect to the server. Try again later.";
      });
    } on TimeoutException catch (_) {
      setState(() {
        hasError = true;
        errorMessage = "Network timeout. Please try again.";
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = "An unexpected error occurred: $e";
      });

      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
    }
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


    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children:  const [
            HomeScreen(),
            ReferEarn(),
            // CustomerScreen(),
            OurProductAndService(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: EdgeInsets.only(bottom: 8.h),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMenuItem(Icons.home, "Home", 0),
                SizedBox(width: 20.w),
                _buildMenuItem(Icons.card_giftcard, "Refer and Earn", 1),

                SizedBox(width: 20.w),
                // BusinessScreen(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const BusinessScreen()));
                  },
                  child: Container(
                    height: 70.h,
                    width: 70.h,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(35.h),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/aj_logo_white.png',
                        height: 70.h,
                        width: 70.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                _buildMenuItem(Icons.business, "Branding", 2),

                SizedBox(width: 20.w),
                _buildMenuItem(Icons.account_circle, "Account", 3),  // Account tab

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActivationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing the dialog by tapping outside
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Make background transparent
          child: Stack(
            children: [
              // GestureDetector to navigate on image click
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ActivateMembershipPage()), // Navigate to the ActivateMembershipPage
                  ).then((_) {
                    Navigator.pop(context); // Pop dialog when navigating back
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0), // Increased border radius
                  child: Image.asset(
                    'assets/images/offers/or.jpg', // Your image asset path
                    width: MediaQuery.of(context).size.width * 0.8, // Adjust width based on screen width
                    height: MediaQuery.of(context).size.height * 0.5, // Increased height
                    fit: BoxFit.cover, // Adjust the fit to cover the area
                  ),
                ),
              ),
              // Close button (cross icon) at the top-right corner with background
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close the dialog when tapped
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6), // Padding around the icon
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5), // Background color for the close icon
                      borderRadius: BorderRadius.circular(20), // Rounded background for the icon
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white, // White color for the close icon
                      size: 15, // Size of the close icon
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }







  Widget _buildMenuItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _pageController.jumpToPage(index);
      },
      child: SizedBox(
        height: 50.h, // Adjusted size to ensure proper display
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28.sp, // Adjust size with ScreenUtil
              color: _selectedIndex == index ? Colors.red : Colors.grey,
            ),
            SizedBox(height: 4.h), // Adjust with ScreenUtil
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp, // Adjust font size with ScreenUtil
                color: _selectedIndex == index ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

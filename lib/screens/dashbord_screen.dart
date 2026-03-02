import 'dart:async';
import 'dart:io';

import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/model/business_mode.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/payment/premium_plans_screen.dart';
import 'package:ajhub_app/screens/business_list.dart';
import 'package:ajhub_app/screens/categories_with_image.dart';
import 'package:ajhub_app/screens/home_screen.dart';
import 'package:ajhub_app/screens/palnner/add_plan_screen.dart';
import 'package:ajhub_app/screens/product_and_service.dart';
import 'package:ajhub_app/screens/profile_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ajhub_app/utils/feature_gate_widget.dart';
import 'package:ajhub_app/screens/locked_feature_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  String referralCode = "Loading...";
  bool isMembershipActive = false;
  bool hasError = false;
  String errorMessage = '';
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
  int directIncome = 0;
  DateTime? userCreatedAt; // NEW
  String? userStatus; // NEW

  @override
  void initState() {
    super.initState();
    // ✅ Register lifecycle observer so we refresh status when app resumes
    WidgetsBinding.instance.addObserver(this);
    fetchUserData();
    fetchBusinessData();
  }

  /// Called whenever the app lifecycle changes.
  /// On [AppLifecycleState.resumed], we re-fetch user data so that
  /// appStore.Status and planLimits are always up-to-date in real time
  /// (e.g. subscription expiry detected as soon as the app foregrounds).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchUserData();
    }
  }

  @override
  void dispose() {
    // ✅ Always remove the observer to avoid memory leaks
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
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
        directTeamCount = userDetail['direct_team_count'] ?? 0;

        // --- EXTRACTION FOR TRIAL LOGIC ---
        userStatus = userDetail['status'];
        if (userDetail['created_at'] != null) {
          userCreatedAt = DateTime.parse(userDetail['created_at']);
        }

        print(
            "direct count $directTeamCount, CreatedAt: $userCreatedAt, Status: $userStatus, PlanID: ${userDetail['subscription_plan_id']}");

        _isLoading = false;

        // ✅ FIX: Update appStore.Status so the HomeAppBar Observer re-renders
        // with the correct 'active' status after a subscription is purchased.
        // Previously, appStore.Status was only set at login and never refreshed,
        // causing the 'Pro' badge to not appear after payment.
        appStore.setStatus(userStatus ?? '');

        // Fetch limits for the user's plan
        fetchAndStorePlanLimits(userPlanId: userDetail['subscription_plan_id']);

        // Check Trial Expiry immediately after user data is loaded
        _checkTrialStatus();
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

  void fetchBusinessData() async {
    try {
      final data = await getBusinessData(businessmodal: []);
      if (mounted) {
        setState(() {
          if (data.isNotEmpty) {
            businessData = data.first;
            // Assuming businessData!.business!.directIncome is where the paid income is stored
            directIncome = businessData?.business?.directIncome ?? 0;
            print("direct income $directIncome");

            // --- CHECK TRIAL EXPIRY (Moved to fetchUserData) ---
            // _checkTrialStatus();
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching business data: $e");
      }
    }
  }

  void _checkTrialStatus() {
    print("[Subscription] Status: $userStatus, CreatedAt: $userCreatedAt");

    // ✅ ACTIVE — valid paid subscription, no action needed
    if (userStatus == 'active') return;

    // ✅ EXPIRED — had a subscription but it lapsed → show dialog then locked plans
    if (userStatus == 'expired') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showTrialExpiredDialog(
            title: 'Subscription Expired',
            message:
                'Your subscription plan has ended. Please renew to continue enjoying all premium features.',
            icon: Icons.refresh_rounded,
          );
        }
      });
      return;
    }

    // ✅ INACTIVE — never paid → give a 7-day grace trial from account creation
    // After 7 days without a subscription, show the paywall
    if (userStatus == 'inactive') {
      if (userCreatedAt == null) return;

      final int daysSinceSignup =
          DateTime.now().difference(userCreatedAt!).inDays;

      print("[Trial] Days since signup: $daysSinceSignup");

      if (daysSinceSignup >= 7) {
        print(
            "[Trial] 7-day trial expired for inactive user. Showing paywall.");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showTrialExpiredDialog(
              title: 'Free Trial Ended',
              message:
                  'Your 7-day free trial has ended. Subscribe to a paid plan to continue using all features.',
              icon: Icons.hourglass_disabled_rounded,
            );
          }
        });
      }
    }
  }

  /// Shows a non-dismissable dialog informing the user that their trial or
  /// subscription has expired, then navigates to the locked PremiumPlansScreen.
  void _showTrialExpiredDialog({
    required String title,
    required String message,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // User MUST tap the button
      builder: (ctx) => PopScope(
        canPop: false, // Prevent system back from closing dialog
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 40, color: Colors.red.shade700),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Close dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PremiumPlansScreen(isLocked: true),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Plans',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20), // Add padding to the sides
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30), // Increase spacing

                // Title Text
                const Text(
                  'Oops! Something went wrong.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .black87, // Slightly darkened text for better contrast
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

                const SizedBox(
                    height: 30), // Increased space between text and button

                // Retry Button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      hasError = false;
                    });
                    fetchUserData();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text("Retry",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    textStyle: const TextStyle(
                      fontSize:
                          18, // Slightly larger font size for better readability
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
      body: PageView(
        clipBehavior: Clip.hardEdge,
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          HomeScreen(
              userReferralCount: directTeamCount,
              referralIncome: directIncome,
              userStatus: userStatus,
              userCreatedAt: userCreatedAt), // <--- Passed Status and CreatedAt
          SubcategoriesScreen(),
          OurProductAndService(),
          ProfileScreen(),
        ],
      ),
      floatingActionButton: FeatureGate(
        feature: 'plan_a_day',
        customLockWidget: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LockedFeatureScreen(
                  featureName: 'Plan A Day',
                  icon: Icons.calendar_month,
                ),
              ),
            );
          },
          backgroundColor: Colors.grey,
          child: const Icon(
            Icons.lock_outline,
            color: Colors.white,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPlanScreen()),
            );
          },
          backgroundColor:
              const Color(0xFFD32F2F), // Use your theme's red color
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 72.h,
          padding: EdgeInsets.symmetric(horizontal: 11.w),
          decoration: BoxDecoration(
            color: Colors.white,
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black12,
            //     blurRadius: 4,
            //     offset: Offset(0, -2),
            //   ),
            // ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home
              _buildMenuItem(Icons.home, "Home", 0),
              // Refer & Earn
              _buildMenuItem(Icons.category, "Categories", 1),
              // Center Logo
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BusinessList()),
                  );
                },
                child: Container(
                  height: 60.h,
                  width: 60.h,
                  margin: EdgeInsets.only(bottom: 18.h), // Slight elevation
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipOval(
                    child: Icon(
                      Icons.business_center_outlined,
                      size: 30.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Services
              _buildMenuItem(Icons.widgets, "Biz Boost", 2),
              // Account
              _buildMenuItem(Icons.account_circle, "Account", 3),
            ],
          ),
        ),
      ),
    );
  }

  void _showActivationDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          true, // Allow dismissing the dialog by tapping outside
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
                    MaterialPageRoute(
                        builder: (context) =>
                            const PremiumPlansScreen()), // Navigate to PremiumPlansScreen
                  ).then((_) {
                    if (!mounted) return;
                    Navigator.pop(context); // Pop dialog when navigating back
                  });
                },
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(24.0), // Increased border radius
                  child: Image.asset(
                    'assets/images/offers/or.jpg', // Your image asset path
                    width: MediaQuery.of(context).size.width *
                        0.8, // Adjust width based on screen width
                    height: MediaQuery.of(context).size.height *
                        0.5, // Increased height
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
                      color: Colors.grey.withOpacity(
                          0.5), // Background color for the close icon
                      borderRadius: BorderRadius.circular(
                          20), // Rounded background for the icon
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
    if (label == 'Biz Boost') {
      return FeatureGate(
        feature: 'business_seminar',
        customLockWidget: _buildMenuItemContent(icon, label, index, true),
        child: _buildMenuItemContent(icon, label, index),
      );
    }
    return _buildMenuItemContent(icon, label, index);
  }

  Widget _buildMenuItemContent(IconData icon, String label, int index,
      [bool isLocked = false]) {
    return GestureDetector(
      onTap: () {
        if (isLocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LockedFeatureScreen(
                featureName: label,
                icon: icon,
              ),
            ),
          );
          return;
        }

        setState(() {
          _selectedIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastLinearToSlowEaseIn,
        );
      },
      child: SizedBox(
        width: 60.w, // Fixed width to align all menu items
        height: 60.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLocked
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(icon, size: 27.sp, color: Colors.grey.shade300),
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 2)
                            ]),
                        child: Icon(Icons.lock_rounded,
                            size: 12.sp, color: Colors.red.shade700),
                      )
                    ],
                  )
                : Icon(
                    icon,
                    size: 27.sp,
                    color: _selectedIndex == index ? Colors.red : Colors.grey,
                  ),
            SizedBox(height: 6.h),
            SizedBox(
              width: 55.w, // Fixed width for label to align under icon
              child: Text(
                label,
                textAlign: TextAlign.center, // Center the text under icon
                overflow: TextOverflow.ellipsis, // Handle long labels
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isLocked
                      ? Colors.grey.shade400
                      : (_selectedIndex == index ? Colors.red : Colors.black),
                  fontWeight: isLocked ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

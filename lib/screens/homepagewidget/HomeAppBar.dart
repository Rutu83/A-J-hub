import 'dart:convert';

import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/screens/notification_page.dart';
import 'package:ajhub_app/screens/payment/premium_plans_screen.dart';
import 'package:ajhub_app/screens/personal_card/personal_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/ring.dart'; // Assuming this is where CustomLoopingIconButton is defined

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  String? _personalPhotoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPersonalPhoto();
  }

  Future<void> _loadPersonalPhoto() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? activeBusinessData = prefs.getString('active_business');

      if (activeBusinessData != null) {
        final activeBusiness = json.decode(activeBusinessData);
        final photoUrl = activeBusiness['personal_photo'];
        if (photoUrl is String && photoUrl.isNotEmpty) {
          setState(() {
            _personalPhotoUrl = photoUrl;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading personal photo: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // White status bar (matches app theme)
        statusBarIconBrightness:
            Brightness.dark, // Dark icons (black) for white background
        statusBarBrightness: Brightness.light, // Light background for iOS
      ),
      child: Container(
        // --- MODIFICATION START ---
        padding: EdgeInsets.fromLTRB(
          8.w,
          12.h,
          8.w,
          15.h,
        ), // Adjusted bottom padding
        decoration: BoxDecoration(
          // 1. Set background back to white
          color: Colors.white,
          // 2. Keep the rounded corners on the bottom
        ),
        // --- MODIFICATION END ---
        child: Row(
          children: [
            // App logo
            CircleAvatar(
              radius: 22.r,
              backgroundImage: const AssetImage('assets/images/app_logo.png'),
              // 4. Reverted background color for the logo
              backgroundColor: Colors.red.shade50,
            ),
            SizedBox(width: 8.w),

            // Greeting Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${appStore.Name}',
                    style: GoogleFonts.b612(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      // 4. Reverted text color to black for readability
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _getGreeting(),
                    style: GoogleFonts.b612(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      // 4. Reverted text color to black
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // --- CONDITIONAL UPGRADE/PRO BUTTON ---
            Observer(
              builder: (_) {
                final isActive = appStore.Status == 'active';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PremiumPlansScreen(),
                      ), // Assuming this is the plan screen
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    margin: EdgeInsets.only(right: 4.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isActive
                            ? [
                                const Color(0xFFD32F2F), // deep red
                                const Color(0xFF8B0000), // dark red
                              ]
                            : [
                                const Color(0xFF424242), // dark grey
                                const Color(0xFF070707), // app primary black
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: (isActive ? Colors.red : Colors.black)
                              .withOpacity(0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isActive ? Icons.verified : Icons.star_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isActive
                              ? (appStore.planName.isNotEmpty
                                  ? appStore.planName
                                  : 'Pro')
                              : 'Upgrade',
                          style: GoogleFonts.b612(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Notification Icon
            IconButton(
              icon: Icon(
                Icons.notifications_active,
                // 4. Reverted icon color to black
                color: Colors.black,
                size: 22.sp,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              },
            ),

            CustomLoopingIconButton(
              // 4. Reverted arrow color to red to match the border
              arrowColor: Colors.red,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PersonalCardPage()),
                );
              },
              child: _buildProfileIcon(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileIcon() {
    if (_isLoading) {
      return SizedBox(width: 24.w, height: 24.h);
    }

    if (_personalPhotoUrl != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: _personalPhotoUrl!,
          width: 24.w,
          height: 24.h,
          fit: BoxFit.cover,
          memCacheWidth: 48,
          memCacheHeight: 48,
          fadeInDuration: const Duration(milliseconds: 150),
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 24.w,
              height: 24.h,
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) =>
              Image.asset('assets/images/app_logo.png'),
        ),
      );
    } else {
      return Icon(
        Icons.person,
        size: 17.sp,
        // 4. Reverted icon color to black
        color: Colors.black,
      );
    }
  }
}

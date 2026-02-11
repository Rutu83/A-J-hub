// refer_earn.dart

import 'dart:async';
import 'dart:io';

import 'package:ajhub_app/model/business_mode.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; // <<<--- ADD THIS IMPORT

// --- THEME COLORS & CONSTANTS ---
const Color kReferPurple = Color(0xFF50238F);
const Color kReferYellow = Color(0xFFFFD138);
const Color kBackgroundColor = Color(0xFFF4F6FA);

// <<<--- ADD THIS CONSTANT
const String _appPackageName = 'com.ajhubdesignapp.ajhub_app';

class ReferEarn extends StatefulWidget {
  @override
  State<ReferEarn> createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> {
  // --- STATE VARIABLES ---
  bool _isLoading = true;
  bool hasError = false;
  String errorMessage = 'An unexpected error occurred.';
  String status = '';
  String referral_code = '';
  var userId;
  var username;
  var email;
  Map<String, dynamic> userData = {};
  Future<Map<String, dynamic>>? futureUserDetail;
  UniqueKey keyForStatus = UniqueKey();
  Future<List<BusinessModal>>? futureBusiness;
  BusinessModal? businessData;
  int directTeamCount = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar transparent
      statusBarIconBrightness:
          Brightness.light, // Icons on status bar are light
    ));
    fetchUserData();
  }

  void fetchUserData() async {
    // ... (Your existing fetchUserData code is perfect, no changes needed)
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
        referral_code = userDetail['referral_code'] ?? '';
        directTeamCount = userDetail['direct_team_count'] ?? 0;
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

  // Make the method async to await file operations
  Future<void> _shareReferralLink() async {
    // Assuming 'referral_code', 'context', and '_appPackageName' are available in your class.

    // Your existing validation logic is good, let's keep it.
    if (referral_code == null || referral_code.isEmpty) {
      // Check for mounted context before showing a SnackBar in an async method.
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Could not generate link. User data not available.")),
      );
      return;
    }

    // --- 1. CONSTRUCT THE TEXT AND LINK (Your existing logic) ---
    const String referralParamKey = 'referral_code';
    // URL-encode the parameters to ensure the link is valid.
    final String encodedParams =
        Uri.encodeComponent('$referralParamKey=$referral_code');
    // Construct the final Play Store link.
    final String referralLink =
        'https://play.google.com/store/apps/details?id=$_appPackageName&referrer=$encodedParams';

    // --- UPDATED SHARE MESSAGE ---
    final String shareText =
        'Join AJHub today and unlock exciting benefits! 🚀\n\n'
        'Greetings! 🎉 I\'ve been enjoying the "Aj Hub: Festival & Business Poster Maker App" and thought you\'d love it too.\n\n'
        'Use my referral code when you sign up: *$referral_code* 🔑\n\n'
        'Click the link to get started:\n'
        '$referralLink';

    // --- 2. TRY TO SHARE WITH IMAGE, FALLBACK TO TEXT-ONLY ---
    try {
      // Load your app logo from assets.
      // Ensure you have 'assets/images/app_logo.png' in your pubspec.yaml
      final ByteData bytes =
          await rootBundle.load('assets/images/app_logo.png');
      final Uint8List list = bytes.buffer.asUint8List();

      // Get a temporary directory to save the file.
      final Directory tempDir = await getTemporaryDirectory();
      final File file = await File('${tempDir.path}/app_logo.png').create();
      await file.writeAsBytes(list);

      // Use shareXFiles to share both the image and the text.
      await Share.shareXFiles(
        [XFile(file.path)], // The image file
        text: shareText,
        subject: 'Join me on AJHub!', // Subject for email sharing
      );
    } catch (e) {
      // If sharing with an image fails for any reason,
      // fall back to sharing only the text.
      print('Error sharing with image: $e');
      await Share.share(shareText, subject: 'Join me on AJHub!');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) return _buildErrorScreen();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kReferPurple))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                _buildHookSection(),
                _buildDetailsSection(),
              ],
            ),
    );
  }

  // --- UI BUILDER METHODS ---

  SliverAppBar _buildAppBar() {
    // ... (Your existing code, no changes needed)
    return SliverAppBar(
      backgroundColor: Colors.red,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.question_mark_outlined, color: Colors.white),
          onPressed: () {/* TODO: Add help/FAQ functionality */},
        ),
      ],
    );
  }

  // In _ReferEarnState class in refer_earn.dart

  Widget _buildReferralCodeSection() {
    // Don't show anything if the username (which is the code) isn't loaded yet.
    if (username == null || (username as String).isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
      child: Column(
        children: [
          Text(
            "Or share your code directly",
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 12.h),
          // This is the styled container for the code and copy button.
          Container(
            padding:
                EdgeInsets.only(left: 24.w, right: 12.w, top: 8.h, bottom: 8.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(50.r), // Pill shape
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The referral code text
                Expanded(
                  child: Text(
                    referral_code, // This is the user's referral code
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: kReferYellow, // Make the code stand out
                      letterSpacing: 2.5, // Adds a premium feel
                    ),
                  ),
                ),
                // The copy button
                IconButton(
                  icon: Icon(Icons.copy_all_rounded, color: Colors.white),
                  onPressed: () {
                    // Logic to copy the code to the clipboard
                    Clipboard.setData(ClipboardData(text: referral_code));

                    // Show a confirmation message to the user
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code copied to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: kReferPurple,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHookSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(bottom: 40.h),
        color: Colors.red,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              Text(
                'Earn ₹100!',
                style: GoogleFonts.poppins(
                  fontSize: 42.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Invite your friends & family to AJHub.\nEarn rewards on Every successful Paid Subscription.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40.h),
              ElevatedButton(
                // <<<--- MODIFIED THIS
                onPressed: _shareReferralLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kReferYellow,
                  foregroundColor: kReferPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 14.h, horizontal: 40.w),
                ),
                child: Text(
                  'Refer a friend',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildReferralCodeSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ... (All your other build methods like _buildDetailsSection, _buildProgressCard, etc. remain unchanged)
  // ... (Paste all your other unchanged methods here)
  SliverToBoxAdapter _buildDetailsSection() {
    return SliverToBoxAdapter(
      child: Container(
        transform: Matrix4.translationValues(0.0, -20.0, 0.0),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressCard(),
              SizedBox(height: 20.h),
              _buildBenefitsRow(),
              SizedBox(height: 24.h),
              Text(
                "Referral Steps", // Renamed from Milestones
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),

              // --- STEP 1 ---
              _buildTierCard(
                tierColor: const Color(0xFF6C5CE7), // Purple
                title: "Step 1",
                description: "Get 7 Days Validity",
                requiredRefers: 1,
                completedRefers: directTeamCount,
              ),

              // --- STEP 2 ---
              _buildTierCard(
                tierColor: const Color(0xFF0984E3), // Blue
                title: "Step 2",
                description: "Get +7 Days Validity (Total 14)",
                requiredRefers: 2,
                completedRefers: directTeamCount,
              ),

              // --- STEP 3 ---
              _buildTierCard(
                tierColor: const Color(0xFF00B894), // Green
                title: "Step 3",
                description: "Get +7 Days Validity (Total 21)",
                requiredRefers: 3,
                completedRefers: directTeamCount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    double progress = (directTeamCount / 100.0).clamp(0.0, 1.0);
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Progress",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10.h,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.red,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  "$directTeamCount/100",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsRow() {
    return Row(
      children: [
        Expanded(
            child: _buildBenefitWidget(
                icon: Icons.star_rounded, text: "5 Points per Refer")),
        SizedBox(width: 12.w),
        Expanded(
            child: _buildBenefitWidget(
                icon: Icons.account_balance_wallet_rounded,
                text: "₹100 Refer Income")),
      ],
    );
  }

  Widget _buildBenefitWidget({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(text,
                style: GoogleFonts.poppins(
                    fontSize: 11.sp, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required Color tierColor,
    required String title,
    required String description,
    required int requiredRefers,
    required int completedRefers,
  }) {
    bool isCompleted = completedRefers >= requiredRefers;
    int referralsForThisTier;

    if (requiredRefers == 1) {
      referralsForThisTier = 1;
    } else if (requiredRefers == 2) {
      referralsForThisTier = 2;
    } else {
      // Step 3
      referralsForThisTier = 3;
    }

    return Opacity(
      opacity: isCompleted ? 0.6 : 1.0, // Dims the card if completed
      child: Card(
        margin: EdgeInsets.only(bottom: 12.h),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: isCompleted ? Colors.green.shade300 : Colors.transparent,
              width: 1.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          leading: Icon(Icons.workspace_premium_rounded,
              color: tierColor, size: 40.sp),
          title: Text(
            title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(description),
          trailing: isCompleted
              ? Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 30.sp)
              : Chip(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  label: Text(
                    "$referralsForThisTier Refers",
                    style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/animation/no_internet_2_lottie.json',
                  width: 250, height: 250),
              const SizedBox(height: 20),
              Text('Oops! Something Went Wrong',
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 10),
              Text(errorMessage,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: fetchUserData,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text("Retry",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kReferPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

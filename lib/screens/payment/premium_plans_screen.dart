import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ajhub_app/screens/payment/airpay_payment_screen.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/model/subscription_plan_model.dart';

class PremiumPlansScreen extends StatefulWidget {
  const PremiumPlansScreen({super.key});

  @override
  State<PremiumPlansScreen> createState() => _PremiumPlansScreenState();
}

class _PremiumPlansScreenState extends State<PremiumPlansScreen> {
  bool isYearly = true; // Default toggle state
  int _selectedPlanIndex = 2; // Default to Pro
  late Future<List<SubscriptionPlan>> _plansFuture;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    _plansFuture = getSubscriptionPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA), // App's Light Grey Background
      body: SafeArea(
        child: Stack(
          children: [
            // --- SCROLLABLE CONTENT ---
            SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: 100.h,
              ), // Space for sticky button
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),
                    // --- HEADER ---
                    _buildHeader(),
                    SizedBox(height: 24.h),

                    // --- TOGGLE ---
                    _buildToggle(),
                    SizedBox(height: 32.h),

                    // --- DYNAMIC PLANS ---
                    FutureBuilder<List<SubscriptionPlan>>(
                      future: _plansFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildLoadingShimmer();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                "Failed to load plans.\nPlease check your connection.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(color: Colors.red),
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              "No plans available at the moment.",
                              style: GoogleFonts.poppins(),
                            ),
                          );
                        }

                        final plans = snapshot.data!;

                        // Ensure selected index is valid
                        if (_selectedPlanIndex >= plans.length) {
                          _selectedPlanIndex = plans.length - 1;
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: plans.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 16.h),
                          itemBuilder: (context, index) {
                            return _buildDynamicPlanCard(plans[index], index);
                          },
                        );
                      },
                    ),

                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),

            // --- STICKY BACK BUTTON (Top Left) ---
            Positioned(
              top: 10.h,
              left: 10.w,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // --- STICKY BOTTOM BUTTON ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildStickyButton(),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildLoadingShimmer() {
    return Column(
      children: [
        Container(height: 200.h, color: Colors.white),
        SizedBox(height: 16.h),
        Container(height: 200.h, color: Colors.white),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Choose Your Plan",
          style: GoogleFonts.poppins(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Dark Text
          ),
        ),
        SizedBox(height: 8.h),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Unlock the full power of ",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade700,
                  fontSize: 14.sp,
                ),
              ),
              TextSpan(
                text: "AJ Hub Business.",
                style: GoogleFonts.poppins(
                  color: Colors.black, // High contrast
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white, // White container
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // Animated Slider
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: isYearly ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              height: 50.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE53935),
                    Color(0xFFC62828),
                  ], // Red gradient
                ),
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isYearly = false),
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Text(
                        "Monthly",
                        style: GoogleFonts.poppins(
                          color: !isYearly ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isYearly = true),
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Yearly",
                          style: GoogleFonts.poppins(
                            color: isYearly ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: isYearly
                                ? Colors.white.withOpacity(0.2)
                                : Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            "Save ~60%",
                            style: GoogleFonts.poppins(
                              color: isYearly ? Colors.white : Colors.black,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DYNAMIC PLAN CARD ---
  Widget _buildDynamicPlanCard(SubscriptionPlan plan, int index) {
    bool isSelected = _selectedPlanIndex == index;
    // Determine style based on slug or recommended status
    // 'basic' (free) usually has simpler style
    // 'pro' or recommended usually has premium style
    bool isPremium = plan.slug == 'pro' || plan.isRecommended;
    bool isFree = plan.priceMonthly == 0 && plan.priceYearly == 0;

    // Border Color
    Color borderColor = Colors.grey.shade200;
    if (isSelected) {
      borderColor = const Color(0xFFE53935);
    }

    // Border Width
    double borderWidth = isSelected ? (isPremium ? 3.0 : 2.0) : 1.0;

    // Shadow
    List<BoxShadow> boxShadow = isSelected
        ? [
            BoxShadow(
              color: isPremium
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 20,
            ),
          ]
        : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)];

    Widget cardContent = Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.name.toUpperCase(),
                style: GoogleFonts.poppins(
                  color: isPremium
                      ? const Color(0xFFE53935)
                      : Colors.grey.shade700,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(
                isPremium
                    ? Icons.workspace_premium
                    : (isFree ? Icons.person_outline : Icons.business_center),
                color: isPremium ? const Color(0xFFE53935) : Colors.grey,
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Price Row
          if (isFree)
            Text(
              "₹0",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 36.sp,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${isYearly ? plan.priceYearly : plan.priceMonthly}",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
                  child: Text(
                    isYearly ? "/yr" : "/mo",
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),

          SizedBox(height: 20.h),

          // Features List
          ...plan.features.map(
            (feature) => _buildFeatureRow(
              feature,
              true,
              // Negative logic if needed (e.g. starts with "No " or contains "Watermark" for free)
              isNegative: isFree && feature.contains("Watermark"),
              accentColor: isPremium || !isFree
                  ? const Color(0xFFE53935)
                  : null,
              textColor: Colors.black87,
            ),
          ),
        ],
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedPlanIndex = index),
          child: cardContent,
        ),
        // Recommended Badge
        if (plan.isRecommended)
          Positioned(
            top: -12.h,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE53935), Color(0xFFC62828)],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                "RECOMMENDED",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureRow(
    String text,
    bool isChecked, {
    Color? accentColor,
    bool isNegative = false,
    Color textColor = Colors.white70,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(
            isNegative ? Icons.do_not_disturb_on : Icons.check,
            color: isNegative ? Colors.grey : (accentColor ?? Colors.grey),
            size: 18.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            // Added Expanded to handling long text
            child: Text(
              text,
              style: GoogleFonts.poppins(color: textColor, fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white, // White Footer
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: FutureBuilder<List<SubscriptionPlan>>(
        future: _plansFuture,
        builder: (context, snapshot) {
          final bool loaded = snapshot.hasData && snapshot.data!.isNotEmpty;

          return Container(
            width: double.infinity,
            height: 55.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFC62828)], // Red gradient
              ),
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE53935).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: !loaded
                  ? null
                  : () {
                      final plans = snapshot.data!;
                      if (_selectedPlanIndex >= plans.length) return;

                      final selectedPlan = plans[_selectedPlanIndex];

                      // Check if it's a free plan
                      if (selectedPlan.priceMonthly == 0 &&
                          selectedPlan.priceYearly == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("You have selected the Free Plan."),
                          ),
                        );
                        return;
                      }

                      String planName = selectedPlan.name;
                      if (isYearly) {
                        planName += " (Yearly)";
                      } else {
                        planName += " (Monthly)";
                      }

                      double amountDouble = isYearly
                          ? selectedPlan.priceYearly.toDouble()
                          : selectedPlan.priceMonthly.toDouble();

                      // Navigate to Payment
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AirpayPaymentScreen(
                            amount: amountDouble,
                            planName: planName,
                            orderId:
                                "ORDER_${DateTime.now().millisecondsSinceEpoch}",
                            planId: selectedPlan.id,
                            period: isYearly ? 'yearly' : 'monthly',
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                loaded ? "Upgrade Now" : "Loading...",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

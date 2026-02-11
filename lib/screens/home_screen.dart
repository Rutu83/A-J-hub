import 'dart:ui'; // Needed for the blur effect

import 'package:ajhub_app/screens/charity_screen.dart';
import 'package:ajhub_app/screens/devotional_blog.dart';
import 'package:ajhub_app/screens/direct_selling_blog.dart';
import 'package:ajhub_app/screens/homepagewidget/BannerSliderSection.dart';
import 'package:ajhub_app/screens/homepagewidget/SubcategorySection.dart';
import 'package:ajhub_app/screens/personal_card/agriculture_section.dart';
import 'package:ajhub_app/screens/personal_card/celebrate_the_movement_section.dart';
import 'package:ajhub_app/screens/personal_card/entrepreneurs_section.dart';
import 'package:ajhub_app/screens/personal_card/temple_of_india_section.dart';
import 'package:ajhub_app/screens/personal_card/todayeventimage.dart';
import 'package:ajhub_app/screens/refer_earn.dart';
import 'package:ajhub_app/screens/temple_slider_section.dart';
import 'package:ajhub_app/screens/trendingsection.dart';
import 'package:ajhub_app/screens/workwithus.dart';
import 'package:ajhub_app/screens/yourdocument_locker.dart';
import 'package:ajhub_app/screens/zoonSection.dart';
import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'homepagewidget/DailyUseCategorySection.dart';
import 'homepagewidget/HomeAppBar.dart';
import 'homepagewidget/UpcomingCategorySection.dart';

// --- NEW POPUP BANNER WIDGET ---

class SubscriptionSuccessPopup extends StatelessWidget {
  final VoidCallback onActionPressed;

  const SubscriptionSuccessPopup({
    Key? key,
    required this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // BackdropFilter creates the blurred background effect
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A3093), Color(0xFFA044FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the dialog fit content
            children: [
              const Text(
                'Congratulations 🎊',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(1, 1))
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '7 Days Free\nSubscription Activated', // Updated to 7 Days
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Colors.white24),
              ),
              const Text(
                'Unlock More 🔑',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'For extended membership, join our Refer & Earn Reward Battle!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor:
                      const Color(0xFFE53935), // A strong red color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: Colors.red.withOpacity(0.5),
                ),
                child: const Text(
                  'Click For More',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- DATA MODELS & CONFIGURATION ---

class ReferralStep {
  final String name;
  final int requiredReferrals; // Referrals needed for this specific step
  final int validityDays;
  final Color color;
  final Color lightColor;

  ReferralStep({
    required this.name,
    required this.requiredReferrals,
    required this.validityDays,
    required this.color,
    required this.lightColor,
  });
}

// --- List of steps: +7 days for each referral ---
final List<ReferralStep> referralSteps = [
  ReferralStep(
      name: 'Step 1',
      requiredReferrals: 1,
      validityDays: 7,
      color: const Color(0xFF6C5CE7), // Purple
      lightColor: const Color(0xFFA29BFE)),
  ReferralStep(
      name: 'Step 2',
      requiredReferrals: 2,
      validityDays: 14, // Total
      color: const Color(0xFF0984E3), // Blue
      lightColor: const Color(0xFF74B9FF)),
  ReferralStep(
      name: 'Step 3',
      requiredReferrals: 3,
      validityDays: 21, // Total
      color: const Color(0xFF00B894), // Green
      lightColor: const Color(0xFF55EFC4)),
];

// --- MAIN HOME SCREEN WIDGET ---

class HomeScreen extends StatefulWidget {
  final int userReferralCount;
  final int referralIncome; // NEW: Passed from Dashboard

  const HomeScreen({
    super.key,
    required this.userReferralCount,
    this.referralIncome = 0, // Default to 0
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  // --- STATE FOR LOADING AND REFERRAL LOGIC ---
  bool _isLoading = true;
  bool _isPopupShown = false;
  ReferralStep? _currentStep;
  ReferralStep? _nextStep;
  double _progress = 0.0;
  int _referralsForNextStage = 0;
  int _referralsMadeInStage = 0;
  bool _hideCongrats = true; // Default to hidden until checked

  // --- WALLET STATE ---
  int _pointsBalance = 0; // Example: 5 points per referral
  int _referralIncome = 0; // Used for UI

  @override
  void initState() {
    super.initState();
    _calculateProgress();
    _checkCongratsVisibility();
    // Simulate a network delay for a better initial loading experience
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // --- ADDED: Show popup after the screen is built and loading is done ---
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // _showInitialPopup(context);
        });
      }
    });
  }

  // --- ADDED: Method to show the popup ---
  void _showInitialPopup(BuildContext context) {
    if (_isPopupShown) return; // Prevents showing it more than once per session

    setState(() {
      _isPopupShown = true; // Mark as shown
    });

    showDialog(
      context: context,
      barrierDismissible: true, // User can tap outside to close
      builder: (BuildContext dialogContext) {
        return SubscriptionSuccessPopup(
          onActionPressed: () {
            // First, close the dialog
            Navigator.of(dialogContext).pop();
            // Then, navigate to the Refer & Earn screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReferEarn()),
            );
          },
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userReferralCount != oldWidget.userReferralCount) {
      // Recalculate if referral count changes from an external source
      _calculateProgress();
    }
  }

  // --- THIS IS THE CORRECTED & MORE ROBUST FUNCTION ---
  void _calculateProgress() {
    int currentUserReferrals = widget.userReferralCount;

    // --- WALLET CALCULATION ---
    _pointsBalance = currentUserReferrals * 5; // 5 Points per referral
    _referralIncome = widget.referralIncome; // Use real income from API

    // --- FIX: Prevents a crash when all steps are completed ---
    try {
      _nextStep = referralSteps.firstWhere(
        (step) => step.requiredReferrals > currentUserReferrals,
      );
    } catch (e) {
      _nextStep = null;
    }

    // Find the current highest achieved step.
    _currentStep = referralSteps
        .where((step) => step.requiredReferrals <= currentUserReferrals)
        .lastOrNull;

    if (_nextStep == null) {
      // --- MAX STEP REACHED ---
      final maxStepRequirement = referralSteps.last.requiredReferrals;

      _progress = 1.0;
      _referralsMadeInStage = currentUserReferrals >= maxStepRequirement
          ? maxStepRequirement
          : currentUserReferrals;
      _referralsForNextStage = maxStepRequirement;

      // Check if we should show congrats
      _checkCongratsVisibility();
    } else {
      // --- PROGRESS TOWARDS NEXT STEP ---
      _referralsForNextStage = _nextStep!.requiredReferrals;
      _referralsMadeInStage = currentUserReferrals;

      // Calculate progress...
      // Since steps are 1, 2, 3... we can just use the previous step's requirement as base
      final int previousStepReferrals = _currentStep?.requiredReferrals ?? 0;
      final int progressInStage = currentUserReferrals - previousStepReferrals;
      final int stageTotal =
          _nextStep!.requiredReferrals - previousStepReferrals;

      _progress = (stageTotal > 0) ? progressInStage / stageTotal : 1.0;

      // Not at max step, so irrelevant, but ensuring it's hidden doesn't hurt
      _hideCongrats = true;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _checkCongratsVisibility() async {
    if (_nextStep != null) return; // Only check if max level reached

    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('congratulations_shown') ?? false;

    if (!hasShown) {
      if (mounted) {
        setState(() {
          _hideCongrats = false; // Show it!
        });
      }
      // Mark as shown for next time
      await prefs.setBool('congratulations_shown', true);
    } else {
      if (mounted) {
        setState(() {
          _hideCongrats = true; // Already shown, keep hidden
        });
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure KeepAlive logic runs
    // --- CONDITIONAL BUILD BASED ON LOADING STATE ---
    if (_isLoading) {
      return _buildSkeletonLoader();
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          clipBehavior: Clip.none,
          slivers: [
            SliverToBoxAdapter(child: HomeAppBar()),
            SliverToBoxAdapter(child: BannerSliderSection()),
            SliverToBoxAdapter(child: UpcomingCategorySection()),
            SliverToBoxAdapter(child: TodayEventsSection()),
            SliverToBoxAdapter(child: TrendingSection()),
            SliverToBoxAdapter(child: SubcategorySection()),

            // --- WALLET SECTION (POINTS & INCOME) ---
            // SliverToBoxAdapter(child: _buildWalletCards()),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              sliver: SliverToBoxAdapter(
                child: SizedBox.shrink(),
                // child: _nextStep == null
                //     ? (_hideCongrats
                //         ? const SizedBox.shrink()
                //         : _buildMaxStepWidget())
                //     : _buildProgressWidget(),
              ),
            ),
            SliverToBoxAdapter(child: ZoomSection()),
            SliverToBoxAdapter(child: DailyUseCategorySection()),

            // 1. Agriculture - Below daily use blog
            SliverToBoxAdapter(child: const AgricultureSection()),

            // _buildBannerSliverRefer("assets/images/img_3.jpg"),
            SliverToBoxAdapter(child: SubcategorySection()),

            // 4. Celebrate The Movement - Above Locker Banner
            SliverToBoxAdapter(child: const CelebrateTheMovementSection()),

            _buildBannerSliver("assets/images/img_1.jpg"), // Locker Banner
            SliverToBoxAdapter(child: DevotionalCategorySection()),

            // 3. Temple Of India - Above work with us banner
            SliverToBoxAdapter(child: const TempleOfIndiaSection()),

            _buildWorkwithusSliver("assets/images/workwithus.jpg"),
            SliverToBoxAdapter(child: SubcategorySection()),
            SliverToBoxAdapter(child: DirectSellingBlogCategorySection()),

            // 2. Entrepreneurs - Above Charity Banner
            SliverToBoxAdapter(child: const EntrepreneursSection()),

            _buildBannerSliverCharity("assets/images/img_2.jpg"),
            SliverToBoxAdapter(
                child: const TempleSliderSection()), // <<< NEW WIDGET

            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          ],
        ),
      ),
    );
  }

  // --- SKELETON LOADER WIDGET ---

  Widget _buildSkeletonLoader() {
    return Scaffold(
      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              // Skeleton for HomeAppBar
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSkeletonBox(height: 12, width: 100),
                          const SizedBox(height: 8),
                          _buildSkeletonBox(height: 20, width: 150),
                        ],
                      ),
                      _buildSkeletonBox(height: 45, width: 45, isCircle: true),
                    ],
                  ),
                ),
              ),

              // Skeleton for BannerSlider
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: _buildSkeletonBox(height: 150, width: double.infinity),
                ),
              ),

              // Skeleton for UpcomingCategorySection
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                        4,
                        (index) => Column(
                              children: [
                                _buildSkeletonBox(
                                    height: 60, width: 60, isCircle: true),
                                const SizedBox(height: 8),
                                _buildSkeletonBox(height: 10, width: 50),
                              ],
                            )),
                  ),
                ),
              ),
              // Skeleton for TodayEvents & Trending
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: _buildSkeletonBox(height: 120, width: double.infinity),
                ),
              ),
              // Skeleton for Referral Progress Card
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                sliver: SliverToBoxAdapter(
                  child: _buildSkeletonBox(height: 180, width: double.infinity),
                ),
              ),
              // Skeleton for Banners
              ...List.generate(
                  3,
                  (index) => SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        sliver: SliverToBoxAdapter(
                          child: _buildSkeletonBox(
                              height: 110, width: double.infinity),
                        ),
                      )),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to create a consistent skeleton box
  Widget _buildSkeletonBox(
      {required double height, double? width, bool isCircle = false}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isCircle ? null : BorderRadius.circular(8),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }

  // --- All your existing helper and build methods remain unchanged below this line ---

  Widget _buildBannerSliver(String imagePath, {BoxFit fit = BoxFit.fill}) {
    // ... same as before
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DocumentLockerScreen()),
            );
          },
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(imagePath), fit: fit),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRammandirSliver(String imagePath, {BoxFit fit = BoxFit.fill}) {
    // ... same as before
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(imagePath), fit: fit),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkwithusSliver(String imagePath, {BoxFit fit = BoxFit.fill}) {
    // ... same as before
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WorkWithUS()),
            );
          },
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(imagePath), fit: fit),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSliverRefer(String imagePath, {BoxFit fit = BoxFit.fill}) {
    // ... same as before
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReferEarn()),
            );
          },
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(imagePath), fit: fit),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSliverCharity(String imagePath,
      {BoxFit fit = BoxFit.fill}) {
    // ... same as before
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CharityScreen()),
            );
          },
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(imagePath), fit: fit),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressWidget() {
    if (_nextStep == null) {
      return const SizedBox.shrink();
    }
    int referralsRemaining = _referralsForNextStage - _referralsMadeInStage;
    const startColor = Color(0xffc31432); // A deep red
    const endColor = Color(0xff240b36); // A deep purple/black

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Step Section
              Expanded(
                child: Column(children: [
                  const Text('CURRENT STEP',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(
                        _currentStep != null
                            ? Icons.check_circle
                            : Icons.lock_open,
                        color: Colors.white,
                        size: 20),
                    const SizedBox(width: 6),
                    Text(_currentStep?.name ?? 'Start',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ]),
                ]),
              ),
              // Next Goal Section
              Expanded(
                child: InkWell(
                  onTap: () {
                    _showRewardDialog(_nextStep!);
                  },
                  child: Column(children: [
                    const Text('NEXT GOAL',
                        style: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.emoji_events,
                          color: Colors.yellow, size: 20),
                      const SizedBox(width: 6),
                      Text(_nextStep!.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow)),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.card_giftcard,
                            color: Colors.yellow, size: 22),
                      )
                    ])
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Progress:',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
            Text('$_referralsMadeInStage / $_referralsForNextStage Referrals',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.white70),
              children: [
                const TextSpan(text: 'Refer '),
                TextSpan(
                    text: '$referralsRemaining more friends',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                const TextSpan(text: ' to unlock '),
                TextSpan(
                    text: '+${_nextStep!.validityDays} Days',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                const TextSpan(text: ' validity!'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showRewardDialog(ReferralStep step) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.emoji_events, color: step.color),
              const SizedBox(width: 8),
              Text('Step Reward: ${step.name}'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'By reaching ${step.name}, you will unlock:',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                _buildRewardRow(
                  icon: Icons.calendar_month,
                  color: Colors.teal,
                  title: '+${step.validityDays} Days Validity',
                  description: 'Extend your free trial.',
                ),
                const SizedBox(height: 12),
                _buildRewardRow(
                  icon: Icons.star,
                  color: Colors.orange,
                  title: '5 Points per Referral',
                  description:
                      'You get points for every single referral you make.',
                ),
                const Divider(height: 24),
                const Text(
                  'Keep going!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete all 3 steps to get a total of 21 days validity.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('GOT IT'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWalletCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 28),
                  const SizedBox(height: 12),
                  const Text("Points Balance",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text("$_pointsBalance Pts",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.currency_rupee,
                      color: Colors.white, size: 28),
                  const SizedBox(height: 12),
                  const Text("Referral Income",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text("₹$_referralIncome",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardRow({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 2),
              Text(description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaxStepWidget() {
    final maxStep = referralSteps.last;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [maxStep.lightColor, maxStep.color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: maxStep.color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 5))
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.military_tech_rounded,
              color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text('Congratulations!',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 2)
                  ])),
          const SizedBox(height: 4),
          Text('You have reached the final step: ${maxStep.name}!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: Colors.white.withOpacity(0.9))),
        ],
      ),
    );
  }
}

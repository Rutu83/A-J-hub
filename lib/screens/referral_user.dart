import 'package:ajhub_app/model/business_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RefferalUserList extends StatelessWidget {
  final List<LevelDownline>? userData;

  const RefferalUserList({super.key, this.userData});

  // Helper method to format currency
  String _formatIncome(double income) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2)
        .format(income);
  }

  @override
  Widget build(BuildContext context) {
    // --- SIMPLIFIED LOGIC: Filter for Level 1 users only ---
    final List<LevelDownline> levelOneUsers =
        (userData ?? []).where((user) => user.level == 1).toList();

    // Calculate total income ONLY from Level 1 referrals
    const double incomePerLevelOneUser = 200.0;
    final double totalLevelOneIncome =
        levelOneUsers.length * incomePerLevelOneUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // A light and clean background
      appBar: AppBar(
        title: Text(
          'My Referrals',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- NEW: Main List ---
          Expanded(
            child: levelOneUsers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    itemCount: levelOneUsers.length,
                    itemBuilder: (context, index) {
                      final user = levelOneUsers[index];
                      return _buildUserCard(user, index + 1);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// A header widget to show summary information.

  /// The main card widget for displaying a single user.
  Widget _buildUserCard(LevelDownline user, int serialNumber) {
    final String joinDate = DateFormat('dd MMM, yyyy').format(user.createdAt);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // Serial Number
            CircleAvatar(
              radius: 16.r,
              backgroundColor: Colors.red,
              child: Text(
                serialNumber.toString(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'UID: ${user.uid}',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            // Join Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Joined',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp, color: Colors.grey.shade500),
                ),
                SizedBox(height: 4.h),
                Text(
                  joinDate,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// A widget to display when there are no referrals.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          SizedBox(height: 20.h),
          Text(
            'No Referrals Yet',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Share your referral code to build your team and start earning!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

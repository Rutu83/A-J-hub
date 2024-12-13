import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Fram3 extends StatelessWidget {
  final String businessName;
  final String phoneNumber;
  final String emailAddress;
  final String address;
  final String website;

  const Fram3({
    super.key,
    required this.businessName,
    required this.phoneNumber,
    required this.emailAddress,
    required this.address,
    required this.website,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Define dynamic width and height for the container
    final containerWidth = screenWidth * 0.97; // 97% of screen width
    final containerHeight = containerWidth; // Keep it square

    return FutureBuilder(
      future: precacheImage(const AssetImage('assets/frames/frm3.png'), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Show the frame with text once the image is loaded
          return Container(
            width: containerWidth,
            height: containerHeight,
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/frames/frm3.png'),
                        fit: BoxFit.cover, // Ensures the image covers the container proportionally
                      ),
                    ),
                  ),
                ),

                // Phone Number Text
                Positioned(
                  bottom: containerHeight * 0.06,
                  left: containerWidth * 0.1, // Align with address text
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.white, size: 14),
                      SizedBox(width: 5.w),
                      _buildDynamicText(phoneNumber, 20, 12.sp),
                    ],
                  ),
                ),

                // Address Text
                Positioned(
                  bottom: containerHeight * 0.01, // Closer to the bottom
                  left: containerWidth * 0.1, // Align with phone number
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 14),
                      SizedBox(
                        width: containerWidth * 0.5, // Allow more space for address
                        child: _buildDynamicText(address, 50, 14.sp), // Increased size
                      ),
                    ],
                  ),
                ),

                // Website Text
                Positioned(
                  bottom: containerHeight * 0.01, // Align at the very bottom
                  right: 0, // Align to the right
                  child: Row(
                    children: [
                      const Icon(Icons.language, color: Colors.white, size: 14),
                      SizedBox(
                        width: containerWidth * 0.3, // Adjust width for website
                        child: _buildDynamicText(website, 40, 12.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Show a CircularProgressIndicator while loading
          return Center(
            child: _buildSkeletonLoader(),
          );
        }
      },
    );
  }

  Widget _buildSkeletonLoader() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skeleton for main image
            Container(
              width: 1.sw,
              height: 0.455.sh,
              decoration: BoxDecoration(
                color: Colors.grey[300]!,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 16.h),
            // Skeleton for frame indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300]!,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicText(String text, int maxCharacters, double fontSize) {
    // If the text exceeds maxCharacters, truncate with ellipsis
    if (text.length > maxCharacters) {
      return Text(
        '${text.substring(0, maxCharacters)}...', // Truncate text
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          height: 1.2,
        ),
      );
    } else {
      // Adjust font size dynamically for shorter text
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.normal,
            height: 1.2,
          ),
        ),
      );
    }
  }
}

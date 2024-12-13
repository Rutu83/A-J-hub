import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Fram1 extends StatelessWidget {
  final String businessName;
  final String phoneNumber;
  final String emailAddress;
  final String address;

  const Fram1({
    super.key,
    required this.businessName,
    required this.phoneNumber,
    required this.emailAddress,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    // Get device dimensions
    final screenWidth = MediaQuery.of(context).size.width;

    // Define dynamic width and height for the container
    final containerWidth = screenWidth * 0.97; // 97% of screen width
    final containerHeight = containerWidth; // Keep it square

    return FutureBuilder(
      future: precacheImage(
        const AssetImage('assets/frames/fr1.png'),
        context,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Show image and text once loading is complete
          return Stack(
            children: <Widget>[
              // Background Frame Image
              Positioned(
                top: 0,
                left: 0,
                child: SizedBox(
                  width: containerWidth,
                  height: containerHeight,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/frames/fr1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              // Business Name
              Positioned(
                top: containerHeight * 0.88, // 88% from the top
                left: containerWidth * 0.02, // 2% from the left
                child: Row(
                  children: [
                    const Icon(Icons.business, color: Colors.white, size: 12),
                    SizedBox(
                      width: containerWidth * 0.09, // Limit width
                      child: _buildDynamicText(businessName, 20, 12.sp),
                    ),
                  ],
                ),
              ),
              // Phone Number
              Positioned(
                top: containerHeight * 0.96, // 96% from the top
                left: containerWidth * 0.02, // 2% from the left
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.white, size: 12),
                    SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      width: containerWidth * 0.2, // Limit width
                      child: _buildDynamicText(phoneNumber, 20, 11.sp),
                    ),
                  ],
                ),
              ),
              // Email
              Positioned(
                top: containerHeight * 0.88, // 88% from the top
                left: containerWidth * 0.62, // 62% from the left
                child: Row(
                  children: [
                    const Icon(Icons.email, color: Colors.white, size: 12),
                    SizedBox(width: 5.w),
                    SizedBox(
                      width: containerWidth * 0.3, // Limit width
                      child: _buildDynamicText(emailAddress, 30, 10.sp),
                    ),
                  ],
                ),
              ),
              // Address
              Positioned(
                top: containerHeight * 0.95, // 95% from the top
                left: containerWidth * 0.62, // 62% from the left
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 12),
                    SizedBox(width: 5.w),
                    SizedBox(
                      width: containerWidth * 0.3, // Limit width
                      child: _buildDynamicText(address, 30, 10.sp),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          // Show CircularProgressIndicator while loading
          return  Center(
            child: _buildSkeletonLoader(),
          );
        }
      },
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
}

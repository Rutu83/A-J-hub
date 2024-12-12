import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Fram2 extends StatelessWidget {
  final String businessName;
  final String phoneNumber;
  final String emailAddress;
  final String address;

  const Fram2({
    Key? key,
    required this.businessName,
    required this.phoneNumber,
    required this.emailAddress,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get device dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define dynamic width and height for the container
    final containerWidth = screenWidth * 0.97; // 90% of screen width
    final containerHeight = containerWidth; // Keep it square

    return Stack(
      children: <Widget>[
        // Background Frame Image
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: containerWidth,
            height: containerHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/frames/fr1.png'),
                fit: BoxFit.cover, // Ensures the image covers the frame properly
              ),
            ),
          ),
        ),
        // Business Name
        Positioned(
          top: containerHeight * 0.88, // 88% from the top
          left: containerWidth * 0.02, // 2% from the left
          child: Text(
            businessName,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.normal,
              height: 1.2, // Slightly increased line height for better readability
            ),
          ),
        ),
        // Phone Number
        Positioned(
          top: containerHeight * 0.96, // 95% from the top
          left: containerWidth * 0.02, // 2% from the left
          child: Text(
            phoneNumber,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.normal,
              height: 1.1,
            ),
          ),
        ),
        // Email
        Positioned(
          top: containerHeight * 0.88, // 88% from the top
          left: containerWidth * 0.64, // 67% from the left
          child: Text(
            emailAddress,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontSize: 10.sp,
              fontWeight: FontWeight.normal,
              height: 1.1,
            ),
          ),
        ),
        // Address
        Positioned(
          top: containerHeight * 0.95, // 95% from the top
          left: containerWidth * 0.64, // 67% from the left
          child: Text(
            address,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.normal,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}
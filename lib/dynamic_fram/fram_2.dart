import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Fram2 extends StatelessWidget {
  final String businessName;
  final String phoneNumber;
  final String emailAddress;
  final String address;

  const Fram2({
    super.key,
    required this.businessName,
    required this.phoneNumber,
    required this.emailAddress,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Define dynamic width and height for the container
    final containerWidth = screenWidth * 0.97; // 90% of screen width
    final containerHeight = containerWidth; // Keep it square

    return FutureBuilder(
      future: precacheImage(const AssetImage('assets/frames/fr2.png'), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Show the actual UI once the image is loaded
          return Stack(
            children: <Widget>[
              // Background Frame Image
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: containerWidth,
                  height: containerHeight,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/frames/fr2.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Phone Number
              Positioned(
                top: containerHeight * 0.81, // 81% from the top
                left: containerWidth * 0.30, // 30% from the left
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
                top: containerHeight * 0.94, // 94% from the top
                left: containerWidth * 0.25, // 25% from the left
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
            ],
          );
        } else {
          // Show a CircularProgressIndicator while loading
          return Center(
            child: CircularProgressIndicator( color: Colors.white,),
          );
        }
      },
    );
  }
}

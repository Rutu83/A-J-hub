import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final containerWidth = screenWidth * 0.97; // 90% of screen width
    final containerHeight = containerWidth; // Keep it square

    return FutureBuilder(
      future: precacheImage(const AssetImage('assets/frames/frm3.png'), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Show the frame with text once the image is loaded
          return Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/frames/frm3.png'),
                      fit: BoxFit.cover, // Covers the container proportionally
                    ),
                  ),
                ),
              ),

              // Phone Number Text
              Positioned(
                top: 4.h, // Dynamically positioned based on screen height
                left: 4.w, // Dynamically positioned based on screen width
                child: Text(
                  phoneNumber,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: 22.sp, // Scales text size
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                ),
              ),

              // Address Text
              Positioned(
                bottom: 5,
                left: 10, // Positioned from the left
                child: Text(
                  address,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: 10.sp, // Scales text size
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                ),
              ),

              // Website Text
              Positioned(
                top: 974.h, // Dynamically positioned based on screen height
                left: 814.w, // Dynamically positioned based on screen width
                child: Text(
                  website,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: 22.sp, // Scales text size
                    fontWeight: FontWeight.normal,
                    height: 1.5,
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final containerWidth = screenWidth * 0.97; // 90% of screen width
    final containerHeight = containerWidth; // Keep it square

    return FutureBuilder(
      future: precacheImage(
          const AssetImage('assets/frames/fr1.png'), context),
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
                child: Text(
                  businessName,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    height: 1.2,
                  ),
                ),
              ),
              // Phone Number
              Positioned(
                top: containerHeight * 0.96, // 96% from the top
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
        } else {
          // Show CircularProgressIndicator while loading
          return Center(
          //  child: CircularProgressIndicator( color: Colors.white,), // Blocks all other content
          );
        }
      },
    );
  }
}

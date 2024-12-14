import 'package:flutter/material.dart';

class Fram2 extends StatelessWidget {

  final String businessName;
  final String phoneNumber;
  final String emailAddress;
  final String address;
  final String website;

  const Fram2({
    super.key,
    required this.businessName,
    required this.phoneNumber,
    required this.emailAddress,
    required this.address,
    required this.website,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9, // 90% of screen width
      height: screenHeight * 0.5, // 50% of screen height
      child: Stack(
        children: <Widget>[
          // Background Image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/frames/frm1.png'),
                  fit: BoxFit.cover, // Scale the image to cover the container
                ),
              ),
            ),
          ),

          // Phone Number Text
          Positioned(
            top: screenHeight * 0.424, // 42% from the top of the screen height
            left: screenWidth * 0.4, // 40% from the left of the screen width
            child: Text(
              phoneNumber,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontSize: screenWidth * 0.025, // Responsive font size
                fontWeight: FontWeight.normal,
                height: 1,
              ),
            ),
          ),

          // Website Text
          Positioned(
            top: screenHeight * 0.45, // 45% from the top
            left: screenWidth * 0.52, // 52% from the left
            child: Text(
              website,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Inter',
                fontSize: screenWidth * 0.025, // Responsive font size
                fontWeight: FontWeight.normal,
                height: 1,
              ),
            ),
          ),

          // Location Text
          Positioned(
            top: screenHeight * 0.477, // 47% from the top
            left: screenWidth * 0.08, // 8% from the left
            child: Text(
              address,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontSize: screenWidth * 0.025, // Responsive font size
                fontWeight: FontWeight.normal,
                height: 1,
              ),
            ),
          ),

          // Email ID Text
          Positioned(
            top: screenHeight * 0.452, // 45% from the top
            left: screenWidth * 0.08, // 8% from the left
            child: Text(
              emailAddress,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Inter',
                fontSize: screenWidth * 0.025, // Responsive font size
                fontWeight: FontWeight.normal,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

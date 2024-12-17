import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class Fram4 extends StatelessWidget {
  final String businessName;
  final String phoneNumber;
  final String emailAddress;
  final String address;
  final String website;

  const Fram4({
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
    final containerWidth = screenWidth * 0.97;
    final containerHeight = containerWidth * 1.05; // Slightly taller frame

    return FutureBuilder(
      future: _simulateFrameLoading(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.grey.shade300,
            ),
          );
        } else {
          return SizedBox(
            width: containerWidth,
            height: containerHeight,
            child: Stack(
              children: [
                // Background Frame Image
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/frames/frm4.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text('Failed to load frame'),
                        );
                      },
                    ),
                  ),
                ),

                Positioned(
                  top: (containerHeight * 0.01 + containerHeight * 0.02) / 2,
                  left: containerWidth * 0.08,
                  child: _buildText(
                    text: phoneNumber,
                    fontSize: containerWidth * 0.035,
                    color: Colors.black,
                  ),
                ),


                // Phone Number (Top Left near first phone icon)
                Positioned(
                  top: (containerHeight * 0.08 + containerHeight * 0.07) / 2,
                  left: containerWidth * 0.08,
                  child: _buildText(
                    text: phoneNumber,
                    fontSize: containerWidth * 0.035,
                    color: Colors.black,
                  ),
                ),

                // Email Address (Bottom Left near mail icon)
                Positioned(
                  bottom: (containerHeight * 0.05 + containerHeight * 0.06) / 2,
                 // bottom: containerHeight * 0.05,
                  left: containerWidth * 0.08,
                  child: _buildText(
                    text: emailAddress,
                    fontSize: containerWidth * 0.030,
                    color: Colors.white,
                  ),
                ),

                // Address (Bottom Left near address icon)


                // Website (Bottom Right near web icon)
                Positioned(
                  bottom: containerHeight * 0.06,
                  right: containerWidth * 0.06,
                  child: _buildText(
                    text: website,
                    fontSize: containerWidth * 0.030,
                    color: Colors.white,
                  ),
                ),

                Positioned(
                  bottom: containerHeight * 0.00,
                  left: containerWidth * 0.08,
                  child: _buildText(
                    text: address,
                    fontSize: containerWidth * 0.030,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // Helper Widget to Build Text
  Widget _buildText({
    required String text,
    required double fontSize,
    required Color color,
  }) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Simulate Frame Loading Delay
  Future<void> _simulateFrameLoading() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}

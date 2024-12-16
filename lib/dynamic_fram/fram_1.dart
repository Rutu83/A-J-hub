import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class Fram1 extends StatelessWidget {
  final String businessName;
  final String phoneNumber;
  final String emailAddress;
  final String address;
  final String website;

  const Fram1({
    Key? key,
    required this.businessName,
    required this.phoneNumber,
    required this.emailAddress,
    required this.address,
    required this.website,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.97;
    final containerHeight = containerWidth;

    return FutureBuilder(
      future: _simulateFrameLoading(), // Simulate loading
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show shimmer loader during loading
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
          // Show the frame and text when loaded
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
                      'assets/frames/frm6.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text('Failed to load frame'),
                        );
                      },
                    ),
                  ),
                ),

                // Email Address (Bottom Left)
                Positioned(
                  bottom: (containerHeight * 0.05 + containerHeight * 0.06) / 2,
                  left: containerWidth * 0.08,
                  child: _buildText(
                    text: emailAddress,
                    fontSize: containerWidth * 0.029,
                    color: Colors.black,
                  ),
                ),

                // Phone Number (Bottom Center)
                Positioned(
                  bottom: containerHeight * 0.11,
                  right: containerWidth * 0.38,
                  child: _buildText(
                    text: phoneNumber,
                    fontSize: containerWidth * 0.029,
                    color: Colors.white,
                  ),
                ),

                // Website (Bottom Right)
                Positioned(
                  bottom: (containerHeight * 0.05 + containerHeight * 0.06) / 2,
                  right: containerWidth * 0.15,
                  child: _buildText(
                    text: website,
                    fontSize: containerWidth * 0.029,
                    color: Colors.black,
                  ),
                ),

                // Address (Bottom Left Below Icons)
                Positioned(
                  bottom: containerHeight * 0.0033,
                  left: containerWidth * 0.08,
                  child: _buildText(
                    text: address,
                    fontSize: containerWidth * 0.029,
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
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading time
  }
}

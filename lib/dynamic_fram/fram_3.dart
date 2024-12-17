import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:flutter/material.dart';

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
    final containerWidth = screenWidth * 0.97;
    final containerHeight = containerWidth * 1.05; // Adjusted frame height

    return FutureBuilder(
      future: _simulateFrameLoading(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Shimmer loader during loading
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
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/frames/frm3.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text('Failed to load frame'),
                        );
                      },
                    ),
                  ),
                ),

                // Phone Number (Top Right)
                Positioned(
                  top: (containerHeight * 0.03 + containerHeight * 0.04) / 2,
                  right: containerWidth * 0.07,
                  child: _buildText(
                    text: phoneNumber,
                    fontSize: containerWidth * 0.030,
                    color: Colors.white,
                  ),
                ),

                // Email Address (Bottom Left aligned with icon)
                Positioned(
                  bottom: containerHeight * 0.10,
                  left: containerWidth * 0.07,
                  child: _buildText(
                    text: emailAddress,
                    fontSize: containerWidth * 0.030,
                    color: Colors.white,
                  ),
                ),

                // Address (Bottom Left Corner)
                Positioned(
                  bottom: containerHeight * 0.02,
                  left: containerWidth * 0.08,
                  child: _buildText(
                    text: address,
                    fontSize: containerWidth * 0.030,
                    color: Colors.white,
                  ),
                ),

                // Website (Bottom Center above red line)
                Positioned(
                  bottom: containerHeight * 0.02,
                  right: containerWidth * 0.07,
                  child: _buildText(
                    text: website,
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
      //  fontWeight: FontWeight.bold,
      ),
    );
  }

  // Simulate Frame Loading Delay
  Future<void> _simulateFrameLoading() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}

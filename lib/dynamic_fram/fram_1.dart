import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class Fram1 extends StatelessWidget {
  final String businessName;
  final String phoneNumber;
  final String emailAddress;
  final String address;
  final String website;

  const Fram1({
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
    final containerHeight = containerWidth;

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
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/frames/frm1.png',
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
                  bottom: containerHeight * 0.06,
                  left: containerWidth * 0.06,
                  child: _buildText(
                    text: emailAddress,
                    fontSize: containerWidth * 0.029,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  bottom: (containerHeight * 0.11 + containerHeight * 0.12) / 2,
                  right: containerWidth * 0.38,
                  child: _buildText(
                    text: phoneNumber,
                    fontSize: containerWidth * 0.029,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  bottom: containerHeight * 0.06,
                  right: containerWidth * 0.13,
                  child: _buildText(
                    text: businessName,
                    fontSize: containerWidth * 0.029,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  bottom: containerHeight * 0.0033,
                  left: containerWidth * 0.06,
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

  Future<void> _simulateFrameLoading() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}

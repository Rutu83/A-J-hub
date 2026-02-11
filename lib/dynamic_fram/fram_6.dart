import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class Fram6 extends StatelessWidget {
  const Fram6({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.97;
    final containerHeight = containerWidth * 1.05;

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
                // No image or text widgets included
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: Colors
                          .transparent, // Placeholder container with transparent background
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<void> _simulateFrameLoading() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}

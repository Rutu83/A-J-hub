import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return Container(
      width: 500.w,
      height: 500.h,
      child: Stack(
        children: [
          // Background
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 500.w,
              height: 500.h,
              color: Colors.transparent,
            ),
          ),
          // Bottom Divider
          Positioned(
            top: 457.h,
            left: 0,
            child: Divider(
              color: const Color.fromRGBO(202, 67, 41, 1),
              thickness: 6,
            ),
          ),
          // Rotated Divider
          Positioned(
            top: 444.h,
            left: 374.w,
            child: Transform.rotate(
              angle: 0.000005008956538086317 * (math.pi / 180),
              child: Divider(
                color: const Color.fromRGBO(202, 67, 41, 1),
                thickness: 6,
              ),
            ),
          ),
          // Rectangle SVGs
          Positioned(
            top: 393.h,
            left: 0,
            child: SvgPicture.asset(
              'assets/images/mail.svg',
              semanticsLabel: 'rectangle10',
              width: 500.w,
              height: 50.h,
            ),
          ),
          Positioned(
            top: 460.h,
            left: 0,
            child: SvgPicture.asset(
              'assets/images/mail.svg',
              semanticsLabel: 'rectangle11',
              width: 500.w,
              height: 40.h,
            ),
          ),
          Positioned(
            top: 460.h,
            left: 416.w,
            child: SvgPicture.asset(
              'assets/images/mail.svg',
              semanticsLabel: 'rectangle12',
              width: 84.w,
              height: 40.h,
            ),
          ),
          // Email ID Text
          Positioned(
            top: 469.h,
            left: 48.w,
            child: Text(
              'Email ID: $emailAddress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontFamily: 'Inter',
              ),
            ),
          ),
          // Business Name Image
          Positioned(
            top: 399.h,
            left: 12.w,
            child: Container(
              width: 30.w,
              height: 22.h,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/frames/fr2.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          // Phone Number Text
          Positioned(
            top: 402.h,
            left: 44.w,
            child: Text(
              'Phone: $phoneNumber',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontFamily: 'Inter',
              ),
            ),
          ),
          // Email Icon
          Positioned(
            top: 470.h,
            left: 18.w,
            child: SvgPicture.asset(
              'assets/images/mail.svg',
              semanticsLabel: 'vector',
              width: 18.w,
              height: 13.h,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OportunityScreen extends StatefulWidget {
  const OportunityScreen({super.key});

  @override
  State<OportunityScreen> createState() => _OportunityScreenState();
}

class _OportunityScreenState extends State<OportunityScreen> {
  final List<String> images = [
    'assets/images/slider/slider2.png',
    'assets/images/slider/slider7.png',
    'assets/images/slider/slider5.png',
    'assets/images/slider/slider3.png',
    'assets/images/slider/slider6.png',
    'assets/images/slider/slider4.png',
    'assets/images/slider/slider8.jpg',

  ];

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        titleSpacing: 7.w,
        centerTitle: true,
        title: Text(
          'Opportunity',
          style: TextStyle(
            fontSize: 20.0.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: screenHeight * 0.75,
              autoPlay: true,
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              viewportFraction: 0.95,
            ),
            items: images.map((imagePath) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: screenWidth * 0.95,
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

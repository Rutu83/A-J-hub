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
    'assets/images/slider/slider1.png',
    'assets/images/slider/slider2.png',
    'assets/images/slider/slider3.png',
    'assets/images/slider/slider4.png',
    'assets/images/slider/slider5.png',
    'assets/images/slider/slider6.png',
    'assets/images/slider/slider7.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        titleSpacing: 7.w,
        centerTitle: true,
        title:Text(
          'Oportunity',
          style: TextStyle(
            fontSize: 20.0.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          CarouselSlider(
            options: CarouselOptions(
              height: 750.0,
              autoPlay: true,
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              viewportFraction: 0.95, // Set to 1.0 to remove space on the sides
            ),
            items: images.map((imagePath) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.fill,
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

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import '../../utils/configs.dart';

class BannerSliderSection extends StatefulWidget {
  const BannerSliderSection({super.key});

  @override
  State<BannerSliderSection> createState() => _BannerSliderSectionState();
}

class _BannerSliderSectionState extends State<BannerSliderSection> {
  late Future<List<String>> _banners;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _banners = fetchBannerData();
  }

  Future<List<String>> fetchBannerData() async {
    const apiUrl = '${BASE_URL}getbanners';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return List<String>.from(
          data.map((banner) => banner['banner_image_url']));
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _banners,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.all(12.w),
            child: SizedBox(
              height: 140.h,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Or fallback image
        }

        final imageUrls = snapshot.data!;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 150.h,
                  autoPlay: true,
                  viewportFraction: 1.0,
                  onPageChanged: (index, _) {
                    setState(() => _currentIndex = index);
                  },
                ),
                items: imageUrls.map((url) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images/app_logo.png'),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageUrls.length, (index) {
                  return Container(
                    width: 6.w,
                    height: 6.h,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentIndex == index ? Colors.black : Colors.grey,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

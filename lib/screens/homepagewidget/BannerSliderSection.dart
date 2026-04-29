import 'dart:convert';

import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/configs.dart';

class BannerSliderSection extends StatefulWidget {
  const BannerSliderSection({super.key});

  @override
  State<BannerSliderSection> createState() => _BannerSliderSectionState();
}

class _BannerSliderSectionState extends State<BannerSliderSection> {
  List<String> _bannerUrls = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. INSTANT LOCAL CACHE LOAD (Eliminates wait time)
    final cachedData = prefs.getString('cached_banners');
    if (cachedData != null) {
      if (mounted) {
        setState(() {
          _bannerUrls = List<String>.from(json.decode(cachedData));
          _isLoading = false;
        });
      }
    }

    // 2. BACKGROUND NETWORK REFRESH (Fetches new data silently)
    try {
      const apiUrl = '${BASE_URL}getbanners';
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final freshBanners = List<String>.from(
            data.map((b) => b['banner_image_url']));
        
        prefs.setString('cached_banners', json.encode(freshBanners));

        if (mounted) {
           setState(() {
              _bannerUrls = freshBanners;
              _isLoading = false;
           });
        }
      }
    } catch (_) {
      if (_bannerUrls.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 16.h),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth * 0.96, // Matches viewportFraction
                height: 164.h, // Represents the slider height minus margin
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              );
            }
          ),
        ),
      );
    } else if (_bannerUrls.isEmpty) {
      return const SizedBox.shrink(); // Fallback if absolutely no network or cache
    }

    final imageUrls = _bannerUrls;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 180.h,
                  autoPlay: true,
                  viewportFraction: 0.96, // Increased width proportion
                  enlargeCenterPage: true,
                  enlargeFactor: 0.15, // Smooth peeking
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  onPageChanged: (index, _) {
                    setState(() => _currentIndex = index);
                  },
                ),
                items: imageUrls.map((url) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF232526), Color(0xFF414345)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // An overlay pattern or just the image
                          CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.fill, // Stretches to fill the container, ensuring no edges are cropped
                            memCacheWidth: 450,
                            memCacheHeight: 200,
                            fadeInDuration: const Duration(milliseconds: 300),
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) =>
                                Image.asset('assets/images/app_logo.png'),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageUrls.length, (index) {
                  final isSelected = _currentIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: isSelected ? 20.w : 8.w,
                    height: 8.h,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade400,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFD32F2F).withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                  );
                }),
              ),
            ],
          ),
        );
  }
}

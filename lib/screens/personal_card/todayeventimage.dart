// lib/screens/homepagewidget/TodayEventsSection.dart

import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/category_selected.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/upcoming_model.dart';

class TodayEventsSection extends StatefulWidget {
  const TodayEventsSection({super.key});

  @override
  State<TodayEventsSection> createState() => _TodayEventsSectionState();
}

class _TodayEventsSectionState extends State<TodayEventsSection>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  List<UpcomingSubcategory> _todayEventsSubcategories = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Check if data is already cached in the global variable (from main.dart)
    if (cachedUpcomingSubcategory != null &&
        cachedUpcomingSubcategory!.isNotEmpty) {
      _todayEventsSubcategories =
          cachedUpcomingSubcategory!.first.subcategories;
      _isLoading = false;
    } else {
      _fetchTodaysEventsData();
    }
  }

  Future<void> _fetchTodaysEventsData() async {
    try {
      final UpcomingSubcategoryResponse response =
          await getUpcomingSubcategories();
      if (!mounted) return;

      setState(() {
        _todayEventsSubcategories = response.subcategories;
        _isLoading = false;
      });
      // Cache is handled in getUpcomingSubcategories
    } catch (e) {
      print("Error fetching data for Today's Events section: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return Container(
        // *** CHANGE: Adjusted height for compact loading state ***
        height: 180.h,
        color: const Color(0xFFF5FDFF),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    if (_todayEventsSubcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      // *** CHANGE: Removed the fixed width to allow the section to be full-width ***
      // width: 125.w, // This line was removed
      color: const Color(0xFFF5FDFF),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // *** CHANGE: Used consistent horizontal padding ***
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _buildSectionTitle("Today's Special"),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            // *** CHANGE: Set height to match the new square card size ***
            height: 110.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              // *** CHANGE: Used consistent horizontal padding for the list ***
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _todayEventsSubcategories.length,
              itemBuilder: (context, index) {
                final subcategory = _todayEventsSubcategories[index];
                String imageUrl = subcategory.images.isNotEmpty
                    ? subcategory.images.first
                    : ''; // Use empty string to trigger error widget

                return _buildItem(
                    context, subcategory.name, imageUrl, subcategory.images);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Reusable Helper Widgets ---

  // No changes to your section title design
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          height: 26.h,
          width: 6.w,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, String title, String imageUrl,
      List<String> images) {
    return InkWell(
      onTap: () {
        if (images.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(
              imagePaths: images,
              title: title,
            ),
          ),
        );
      },
      child: Container(
        // *** CHANGE: Set width to match the new compact size ***
        width: 100.w,
        // *** CHANGE: Set margin to match the new consistent spacing ***
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(width: 110.w, color: Colors.grey[300]),
            errorWidget: (context, url, error) =>
                Image.asset('assets/images/app_logo.png'),
          ),
        ),
      ),
    );
  }
}

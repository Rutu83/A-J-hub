// lib/screens/homepagewidget/agriculture_section.dart

import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/category_selected.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/upcoming_model.dart';

class AgricultureSection extends StatefulWidget {
  const AgricultureSection({super.key});

  @override
  State<AgricultureSection> createState() => _AgricultureSectionState();
}

class _AgricultureSectionState extends State<AgricultureSection> {
  bool _isLoading = true;
  List<UpcomingSubcategory> _agricultureSubcategories = [];

  @override
  void initState() {
    super.initState();
    _fetchAgricultureData();
  }

  Future<void> _fetchAgricultureData() async {
    try {
      // Use the new API function
      final UpcomingSubcategoryResponse response =
          await getAgricultureSubcategories();
      if (!mounted) return;

      setState(() {
        _agricultureSubcategories = response.subcategories;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching data for Agriculture section: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 180.h,
        color: const Color(0xFFF5FDFF),
        child:
            const Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    if (_agricultureSubcategories.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if there's no data
    }

    return Container(
      color: const Color(0xFFF5FDFF),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _buildSectionTitle("Agriculture"), // Changed title
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 110.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _agricultureSubcategories.length,
              itemBuilder: (context, index) {
                final subcategory = _agricultureSubcategories[index];
                String imageUrl = subcategory.images.isNotEmpty
                    ? subcategory.images.first
                    : '';

                return _buildItem(
                    context, subcategory.name, imageUrl, subcategory.images);
              },
            ),
          ),
        ],
      ),
    );
  }

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
        width: 100.w,
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

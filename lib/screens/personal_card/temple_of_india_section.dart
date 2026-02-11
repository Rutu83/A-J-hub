// lib/screens/homepagewidget/temple_of_india_section.dart

import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/category_selected.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/upcoming_model.dart';

class TempleOfIndiaSection extends StatefulWidget {
  const TempleOfIndiaSection({super.key});

  @override
  State<TempleOfIndiaSection> createState() => _TempleOfIndiaSectionState();
}

class _TempleOfIndiaSectionState extends State<TempleOfIndiaSection> {
  bool _isLoading = true;
  List<UpcomingSubcategory> _templeOfIndiaSubcategories = [];

  @override
  void initState() {
    super.initState();
    _fetchTempleData();
  }

  Future<void> _fetchTempleData() async {
    try {
      final UpcomingSubcategoryResponse response =
          await getTempleOfIndiaSubcategories();
      if (!mounted) return;

      setState(() {
        _templeOfIndiaSubcategories = response.subcategories;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching data for Temple Of India section: $e");
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

    if (_templeOfIndiaSubcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: const Color(0xFFF5FDFF),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _buildSectionTitle("Temple Of India"), // Changed title
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 110.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _templeOfIndiaSubcategories.length,
              itemBuilder: (context, index) {
                final subcategory = _templeOfIndiaSubcategories[index];
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

  // Re-usable helper widgets (same as before)
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
            errorWidget: (context, url, error) => Container(
              width: 110.w,
              color: Colors.grey[200],
              child: const Icon(Icons.error, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

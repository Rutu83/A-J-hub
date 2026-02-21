import 'package:ajhub_app/model/subcategory_model.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/withoutfram_category_selected.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ZoomSection extends StatefulWidget {
  const ZoomSection({super.key});

  @override
  State<ZoomSection> createState() => _ZoomSectionState();
}

class _ZoomSectionState extends State<ZoomSection> {
  bool _isLoading = true;
  List<Subcategory> _trendingSubcategories = [];

  @override
  void initState() {
    super.initState();
    _fetchTrendingData();
  }

  Future<void> _fetchTrendingData() async {
    try {
      final SubcategoryResponse response = await fetchZoomBgCategories();
      if (!mounted) return;

      setState(() {
        _trendingSubcategories = response.subcategories;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching zoom background categories: $e");
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
        height: 190.h,
        color: const Color(0xFFF6F6FF),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    if (_trendingSubcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: const Color(0xFFF6F6FF),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _buildSectionTitle("Zoom Background"),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 155.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _trendingSubcategories.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final subcategory = _trendingSubcategories[index];

                String imageUrl = subcategory.images.isNotEmpty
                    ? subcategory.images.first
                    : ''; // Fallback

                return _buildItem(
                    context, subcategory.name, imageUrl, subcategory.images);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

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
            builder: (context) => WithoutFramCategorySelected(
              imagePaths: images,
              title: title,
            ),
          ),
        );
      },
      child: Container(
        // The standard width for all cards
        width: 110.w,
        // The standard margin for all cards
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            border: const Border(
                bottom: BorderSide(
              color: Colors.white,
            )),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.9),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                // Standard square dimensions for the image part
                width: 110.w,
                height: 110.h,
                fit: BoxFit.cover,

                placeholder: (context, url) => Container(
                    width: 110.w, height: 110.h, color: Colors.grey[300]),

                errorWidget: (context, url, error) =>
                    Image.asset('assets/images/app_logo.png'),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    // Standard single line for the title
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

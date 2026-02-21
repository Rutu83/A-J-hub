import 'package:ajhub_app/model/categories_subcategories_modal%20.dart';
import 'package:ajhub_app/screens/category_selected.dart';
import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../network/rest_apis.dart';

class FestivalCategorySection extends StatefulWidget {
  const FestivalCategorySection({super.key});

  @override
  State<FestivalCategorySection> createState() =>
      _FestivalCategorySectionState();
}

class _FestivalCategorySectionState extends State<FestivalCategorySection> {
  late Future<CategoryWithSubcategory?> _festivalCategory;

  @override
  void initState() {
    super.initState();
    _festivalCategory = fetchFestivalCategory();
  }

  Future<CategoryWithSubcategory?> fetchFestivalCategory() async {
    final response = await getCategoriesWithSubcategories();
    return response.categories.firstWhere(
      (cat) => cat.name.toLowerCase() == 'festival',
      orElse: () => CategoryWithSubcategory(name: '', subcategories: []),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CategoryWithSubcategory?>(
      future: _festivalCategory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.subcategories.isEmpty) {
          return const SizedBox.shrink(); // No data fallback
        }

        final category = snapshot.data!;
        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Festival'),
              SizedBox(height: 5.h),
              SizedBox(
                height: 120.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: category.subcategories.length,
                  itemBuilder: (context, index) {
                    final sub = category.subcategories[index];
                    String imageUrl = sub.images.isNotEmpty
                        ? sub.images[0]
                        : 'assets/images/default_festival.jpg';

                    return _buildItem(context, sub.name, imageUrl, sub.images);
                  },
                ),
              ),
            ],
          ),
        );
      },
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
        width: 120.w,
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 120.w,
                height: 90.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 120.w,
                    height: 90.h,
                    color: Colors.grey[300],
                  ),
                ),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/images/app_logo.png'),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 120.w,
            margin: EdgeInsets.only(right: 8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

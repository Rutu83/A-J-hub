import 'dart:math'; // Imported for min() function

import 'package:ajhub_app/model/subcategory_model.dart';
import 'package:ajhub_app/screens/category_selected.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for consistent font

import '../../network/rest_apis.dart';
import '../../utils/shimmer/shimmer.dart';

class SubcategorySection extends StatefulWidget {
  const SubcategorySection({super.key});

  @override
  State<SubcategorySection> createState() => _SubcategorySectionState();
}

class _SubcategorySectionState extends State<SubcategorySection> {
  late Future<List<Subcategory>> _subcategories;

  @override
  void initState() {
    super.initState();
    _subcategories = fetchSubcategories();
  }

  Future<List<Subcategory>> fetchSubcategories() async {
    final response = await getSubCategories();
    return response.subcategories;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Subcategory>>(
      future: _subcategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // *** CHANGE: Using the new, more accurate skeleton loader ***
          return _buildSkeletonLoading();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final subcategories = snapshot.data!;
        final itemCount = min(3, subcategories.length);

        return ListView.builder(
          itemCount: itemCount,
          shrinkWrap: true,
          clipBehavior: Clip.none,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemBuilder: (context, index) {
            final subcategory = subcategories[index];
            return _buildSubcategoryRow(subcategory);
          },
        );
      },
    );
  }

  /// Builds a single row for a subcategory, containing a title and a horizontal list of images.
  Widget _buildSubcategoryRow(Subcategory subcategory) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        children: [
          // The Title Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            // *** CHANGE: Switched to the modern, consistent title style ***
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subcategory.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff333333),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategorySelected(
                          imagePaths: subcategory.images,
                          title: subcategory.name,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // The Horizontal Image List - size is already correct
          SizedBox(
            height: 110.h,
            child: ListView.builder(
              shrinkWrap: true,
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: subcategory.images.length,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemBuilder: (context, index) {
                return _buildImageCard(
                  subcategory.name,
                  subcategory.images[index],
                  subcategory.images,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single compact image card. The sizing is already consistent.
  Widget _buildImageCard(
      String title, String imageUrl, List<String> fullImages) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(
              imagePaths: fullImages,
              title: title,
            ),
          ),
        );
      },
      child: Container(
        width: 110.w,
        margin: EdgeInsets.only(right: 16.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(color: Colors.white),
            ),
            errorWidget: (context, url, error) =>
                Image.asset('assets/images/app_logo.png'),
          ),
        ),
      ),
    );
  }

  /// The new loading placeholder that accurately reflects the final UI.
  Widget _buildSkeletonLoading() {
    return ListView.builder(
      itemCount: 2, // Show 2 placeholder rows
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            children: [
              // Title Placeholder
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 22.h,
                        width: 180.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 18.h,
                        width: 50.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              // Card Placeholders
              SizedBox(
                height: 110.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemBuilder: (context, index) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 110.w,
                      margin: EdgeInsets.only(right: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/model/upcoming_model.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/category_selected.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // Import Shimmer package

// Your custom clipper is preserved, no changes here.
class DateTagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double curveRadius = 20.0;
    path.lineTo(0, 0);
    path.lineTo(size.width - curveRadius, 0);
    path.arcToPoint(
      Offset(size.width, curveRadius),
      radius: Radius.circular(curveRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class UpcomingCategorySection extends StatefulWidget {
  const UpcomingCategorySection({super.key});

  @override
  State<UpcomingCategorySection> createState() =>
      _UpcomingCategorySectionState();
}

class _UpcomingCategorySectionState extends State<UpcomingCategorySection>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  List<UpcomingSubcategory> _upcomingItems = [];

  @override
  bool get wantKeepAlive => true; // Keep state when navigating

  // No changes to any of the data fetching logic
  @override
  void initState() {
    super.initState();
    // Check if data is already cached in the global variable (from main.dart)
    if (cachedUpcomingSubcategory != null &&
        cachedUpcomingSubcategory!.isNotEmpty) {
      _upcomingItems = cachedUpcomingSubcategory!.first.subcategories;
      _isLoading = false;
    } else {
      _fetchUpcomingData();
    }
  }

  Future<void> _fetchUpcomingData() async {
    try {
      final UpcomingSubcategoryResponse response =
          await getUpcomingSubcategories();
      if (!mounted) return;
      List<UpcomingSubcategory> fetchedItems = response.subcategories;

      fetchedItems.sort((a, b) {
        final dateA = a.event_date;
        final dateB = b.event_date;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });

      setState(() {
        _upcomingItems = fetchedItems;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching upcoming categories: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    if (_isLoading) {
      return _buildShimmer();
    }

    if (_upcomingItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: _buildSectionTitle("Upcoming Category"),
          ),
          SizedBox(height: 12.h), // *** CHANGE: Slightly reduced spacing ***
          SizedBox(
            // *** CHANGE: Increased height to prevent overflow ***
            height: 160.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 7.w, right: 4.w),
              itemCount: _upcomingItems.length,
              itemBuilder: (context, index) {
                final item = _upcomingItems[index];
                return Container(
                  margin: EdgeInsets.only(right: 12.w),
                  child: _buildItem(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Builder Methods ---

  // No changes to your section title design
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          height: 24.h,
          width: 5.w,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
      ],
    );
  }

  /// Builds the composite widget: the card + the title below it.
  Widget _buildItem(UpcomingSubcategory item) {
    final displayName = item.name.split(' - ').first;

    return SizedBox(
      // Width for horizontal items
      width: 110.w,
      // Fixed height to match parent ListView constraint (160.h)
      height: 158.h,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The visual card part
          SizedBox(
            height: 108.h, // Slightly reduced from 110.h
            child: _buildItemCard(item),
          ),
          // Reduced spacing between card and text
          SizedBox(height: 6.h),
          // The title text below the card
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp, // Reduced from 13.sp
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Builds the card itself, with the image and the custom date tag.
  /// No design changes were made here, only the parent container's size was changed.
  Widget _buildItemCard(UpcomingSubcategory item) {
    final displayName = item.name.split(' - ').first;
    final date = item.event_date;
    final imageUrl = item.images.isNotEmpty ? item.images.first : '';

    return GestureDetector(
      onTap: () {
        if (item.images.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(
              imagePaths: item.images,
              title: displayName,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(0.15),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          // Your unique large border radius is preserved
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Stack(
          children: [
            // Background Image Area
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22.r),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: Colors.red.withOpacity(0.3))),
                        errorWidget: (context, url, error) => Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey.shade400,
                            size: 40.sp),
                      )
                    : Center(
                        child: Icon(Icons.image_outlined,
                            color: Colors.grey.shade400, size: 40.sp)),
              ),
            ),
            // Your unique Date Tag design is preserved
            if (date != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 14,
                child: ClipPath(
                  clipper: DateTagClipper(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    color: Colors.red,
                    child: Center(
                      child: Text(
                        formatDisplayDate(date),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildShimmer() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: _buildSectionTitle("Upcoming Category"),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 155.h,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: 7.w, right: 4.w),
                itemCount: 4, // Show 4 placeholder items
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: 12.w),
                    width: 110.w,
                    child: Column(
                      children: [
                        Container(
                          height: 110.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 12.sp,
                          width: 80.w,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String formatDisplayDate(String dateString) {
  // If the input string is empty or invalid, return it as is.
  if (dateString.isEmpty) {
    return '';
  }

  try {
    // 1. Parse the incoming string into a DateTime object.
    final dateTime = DateTime.parse(dateString);

    final formatter = DateFormat('d MMM yyyy');

    // 3. Return the formatted date.
    return formatter.format(dateTime);
  } catch (e) {
    // If parsing fails (e.g., invalid date format), return the original string.
    // This prevents the app from crashing on bad data.
    print("Error formatting date: $e");
    return dateString;
  }
}

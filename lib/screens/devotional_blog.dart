import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/model/devotation_model.dart';
import 'package:ajhub_app/screens/category_topics.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../network/rest_apis.dart';
import '../../utils/shimmer/shimmer.dart';

class DevotionalCategorySection extends StatefulWidget {
  const DevotionalCategorySection({super.key});

  @override
  State<DevotionalCategorySection> createState() =>
      _DevotionalCategorySectionState();
}

class _DevotionalCategorySectionState extends State<DevotionalCategorySection>
    with AutomaticKeepAliveClientMixin {
  late Future<List<DevotationCategory>> _dailyItems;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _dailyItems = fetchDevotionalItems();
  }

  Future<List<DevotationCategory>> fetchDevotionalItems() async {
    final response =
        await getDevotationUseWithSubcategory(); // returns DaillyuseResponse
    return response.subcategories; // which is List<DaillyCategory>
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Prepare initial data from global cache if available
    List<DevotationCategory>? initialData;
    if (cacheddDevotionalusecategory != null &&
        cacheddDevotionalusecategory!.isNotEmpty) {
      initialData = cacheddDevotionalusecategory!.first.subcategories;
    }

    return FutureBuilder<List<DevotationCategory>>(
      initialData: initialData,
      future: _dailyItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) { // Only show loading if no data
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildSectionTitle(),
              _buildLoadingGrid(),
            ],
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 16,
            ),
            _buildSectionTitle(),
            _buildGrid(items),
          ],
        ); // Now items is List<DaillyCategory>
      },
    );
  }

  Widget _buildGrid(List<DevotationCategory> items) {
    // Use MediaQuery to determine responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 6 : 4; // 6 for tablets, 4 for phones

    int rowCount = (items.length / crossAxisCount).ceil();
    double rowHeight = 120.h;
    double gridHeight = rowCount * rowHeight;

    return GridView.builder(
      primary: false,
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        vertical: 18,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 5.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.88,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final imageUrl = item.images.isNotEmpty
            ? item.images[0]
            : 'assets/images/placeholder.jpg';

        final topicMaps = item.images.map((url) => {'image': url}).toList();

        return _buildItemCard(item.name, imageUrl, topicMaps, context);
      },
    );
  }

  Widget _buildItemCard(String title, String imageUrl,
      List<Map<String, String>> topicMaps, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (topicMaps.isEmpty) {
          _showEmptyPopup(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryTopics(title: title, images: topicMaps),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 70.w,
              height: 68.h, // Slightly reduced from 70.h
              fit: BoxFit.fill,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 80.w,
                  height: 68.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.white,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 80.w,
                height: 68.h,
                color: Colors.grey[200],
                child: const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
          SizedBox(height: 2.h), // Reduced from 4.h
          Text(
            title,
            style: TextStyle(fontSize: 9.sp), // Reduced from 10.sp
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 5,
        ),
        Container(
          height: 26.h,
          width: 6.w,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        SizedBox(width: 18.w),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Devotional',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget _buildLoadingGrid() {
    // Use MediaQuery to determine responsiveness for loading grid too
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 6 : 4;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          SizedBox(
            height: 260.h,
            child: GridView.builder(
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 15.h,
                childAspectRatio: 0.80,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 80.w,
                        height: 75.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 60.w,
                        height: 10.h,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEmptyPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('No Topics Available'),
        content: const Text('There are no topics to display at the moment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}

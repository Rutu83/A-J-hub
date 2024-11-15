import 'package:allinone_app/model/categories_subcategories_modal%20.dart';
import 'package:allinone_app/model/daillyuse_modal.dart';
import 'package:allinone_app/model/subcategory_model.dart';
import 'package:allinone_app/screens/category_topics.dart';
import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:allinone_app/screens/category_selected.dart';

import '../network/rest_apis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _imageUrls = [
    'https://cdn1.tripoto.com/media/filter/tst/img/2052077/Image/1695366505_main4.jpg.webp',
    'https://idolkart.com/cdn/shop/articles/What_happened_to_Krishna_s_body_after_death.jpg',
    'https://www.financialexpress.com/wp-content/uploads/2023/01/netaji.jpg',
  ];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  SubcategoryResponse? subcategoryData;
  DaillyuseResponse? daillyuseData;
  CategoriesWithSubcategoriesResponse? categoriesData;



  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    fetchCategoriesData();
    fetchSubcategoryData();
    fetchDailyUseCategoryData();
  }

  Future<void> fetchDailyUseCategoryData() async {
    try {
      final data = await getDailyUseWithSubcategory();
      setState(() {
        daillyuseData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        if (kDebugMode) {
          print(e);
        }
        errorMessage = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }


  Future<void> fetchSubcategoryData() async {
    try {
      final data = await getSubCategories();
      setState(() {
        subcategoryData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchCategoriesData() async {
    try {
      final data = await getCategoriesWithSubcategories();
      setState(() {
        categoriesData = data;
        if (kDebugMode) {
          print(categoriesData);
        }
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Failed to load categories data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        titleSpacing: 7.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: CircleAvatar(
            radius: 20.0.r,
            backgroundImage: const NetworkImage(
                'https://miro.medium.com/v2/resize:fit:1400/1*AxTSMdh-xZoluQ10nkqqrg.png'),
            backgroundColor: Colors.black,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Hello, AIO',
                    style: TextStyle(
                      fontSize: 16.0.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Good Morning',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.notifications_active,
                size: 22.0.sp,
                color: Colors.black,
              ),
              onPressed: () {
                // Handle notification icon tap
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBannerSlider(),
            _buildUpcomingCategorySection(),
            const SizedBox(height: 10),
            _buildFestivalCategorySection(),
            isLoading ? _buildSkeletonLoading() : _buildSubcategorySections(),
            const SizedBox(height: 10),
            _buildDailyUseSection(context),

          ],
        ),
      ),
    );
  }


  Widget _buildBannerSlider() {
    return Padding(
      padding: EdgeInsets.all(8.0.w),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 150.h,
                autoPlay: true,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: _imageUrls.map((url) {
                return Builder(
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15.0), // Apply border radius here
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _imageUrls.map((url) {
              int index = _imageUrls.indexOf(url);
              return Container(
                width: 6.0.w,
                height: 6.0.h,
                margin: EdgeInsets.symmetric(vertical: 5.0.h, horizontal: 2.0.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index ? Colors.black : Colors.grey,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCategorySection() {
    if (isLoading) {
      return _buildSkeletonLoading();
    }

    if (hasError) {
      return SizedBox(
        height: 100.h,
        child: Center(
          child: Text(
            errorMessage,
            style: TextStyle(fontSize: 16.sp, color: Colors.red),
          ),
        ),
      );
    }

    if (categoriesData == null) {
      return const SizedBox.shrink(); // Return an empty widget if no data
    }

    List<Widget> items = [];
    String sectionTitle = 'Upcoming';
    var upcomingCategory = categoriesData!.categories.firstWhere(
          (category) => category.name.toLowerCase() == 'upcoming',
      orElse: () => CategoryWithSubcategory(name: 'No Upcoming', subcategories: []),
    );

    if (upcomingCategory.subcategories.isEmpty) {
      return const SizedBox.shrink(); // Return an empty widget if no subcategories
    }

    for (var subcategory in upcomingCategory.subcategories) {
      String imageUrl = subcategory.images.isNotEmpty ? subcategory.images[0] : 'assets/images/placeholder.jpg';
      items.add(_buildUpcomingCardItem(subcategory.name, imageUrl, subcategory.images, showTitle: true));
    }

    return _buildUpcomingHorizontalCard(sectionTitle: sectionTitle, items: items);
  }

  Widget _buildUpcomingCardItem(String title, String imageUrl, List<String> images, {bool showTitle = true}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(imagePaths: images),
          ),
        );
      },
      child: Container(
        width: 101.w,
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.shade50),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 90.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: imageUrl.startsWith('http')
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey,
                      child: const Icon(Icons.error),
                    );
                  },
                )
                    : Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey,
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
            ),
            if (showTitle) SizedBox(height: 6.h),
            if (showTitle)
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

  Widget _buildFestivalCategorySection() {
    if (isLoading) {
      return _buildSkeletonLoading();
    }

    if (hasError) {
      return Container();
    }

    if (categoriesData == null) {
      return const SizedBox.shrink();
    }

    List<Widget> items = [];
    String sectionTitle = 'Festival';

    var festivalCategory = categoriesData!.categories.firstWhere(
          (category) => category.name.toLowerCase() == 'festival',
      orElse: () => CategoryWithSubcategory(name: 'No Festival', subcategories: []),
    );

    if (festivalCategory.subcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    for (var subcategory in festivalCategory.subcategories) {
      if (subcategory.images.isNotEmpty) {
        items.add(_buildCardItem(subcategory.name, subcategory.images[0], subcategory.images, showTitle: false));
      }
    }

    return _buildHorizontalCardSection(sectionTitle: sectionTitle, items: items);
  }

  Widget _buildSubcategorySections() {
    if (isLoading) {
      return _buildSkeletonLoading(); // Show skeleton loading when data is loading
    }

    if (hasError) {
      return Container(
        height: 200.h,
        width: 300.w,
        decoration: const BoxDecoration(),
        child: Lottie.asset('assets/animation/error_lottie.json'),
      );
    }

    if (subcategoryData == null || subcategoryData!.subcategories.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 16.sp, color: Colors.black),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSubcategory(),
        ],
      ),
    );
  }

  Widget _buildSubcategory() {
    List<Widget> sections = [];

    for (var subcategory in subcategoryData!.subcategories) {
      List<Widget> items = subcategory.images.map((imageUrl) {
        return _buildCardItem(subcategory.name, imageUrl, subcategory.images, showTitle: false);
      }).toList();

      subcategory.images.map((imageUrl) {
        return {'image': imageUrl};
      }).toList();

      sections.add(_buildHorizontalCardSection(
        sectionTitle: subcategory.name,
        items: items,
      ));
    }

    return Column(children: sections);
  }



  Widget _buildCardItem(String title, String imageUrl, List<String> images, {bool showTitle = true}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(imagePaths: images),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 90.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
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
                  errorWidget: (context, url, error) => Container(
                    width: 120.w,
                    height: 90.h,
                    color: Colors.grey,
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
            if (showTitle) SizedBox(height: 6.h),
            if (showTitle)
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



  Widget _buildDailyUseSection(BuildContext context) {
    // List to store daily use items
    List<Widget> items = [];

    if (daillyuseData != null) {
      for (var category in daillyuseData!.subcategories) {
        String title = category.name;
        String imageUrl = category.images.isNotEmpty ? category.images[0] : 'assets/images/placeholder.jpg';

        // Convert List<String> to List<Map<String, String>>
        List<Map<String, String>> topicMaps = category.images.map((url) => {'image': url}).toList();

        items.add(_buildDailyUseItemCard(title, imageUrl, topicMaps, context));
      }
    }

    // Calculate number of rows required for the grid
    int crossAxisCount = 4; // Number of items per row
    int rowCount = (items.length / crossAxisCount).ceil();
    double rowHeight = 120.h; // Approximate height of each grid item, including spacing

    // Calculate dynamic height based on the number of rows
    double gridHeight = rowCount * rowHeight;

    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 26.h,
                  width: 6.w,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(5.r),
                      bottom: Radius.circular(5.r),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Daily Use',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            SizedBox(
              height: gridHeight,
              child: GridView.builder(
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 15.h,
                  childAspectRatio: 0.80,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return items[index];
                },
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }


  Widget _buildDailyUseItemCard(String title, String imageUrl, List<Map<String, String>> topicMaps, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryTopics(
              title: title,
              images: topicMaps,
            ),
          ),
        );
      },
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            width: 80.w,
            height: 75.h,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 80.w,
                height: 75.h,
                color: Colors.grey[300],
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 80.w,
              height: 75.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.error, color: Colors.red),
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 10.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }








  Widget _buildSkeletonLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(5, (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Container(height: 140.h, color: Colors.white),
        )),
      ),
    );
  }

  Widget _buildUpcomingHorizontalCard({required String sectionTitle, required List<Widget> items}) {
    return Container(
      color: const Color(0xFFFFF5F5),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 26.h,
                  width: 6.w,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(5.r),
                      bottom: Radius.circular(5.r),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  sectionTitle,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            SizedBox(
              height: 120.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: items,
              ),
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCardSection({required String sectionTitle, required List<Widget> items}) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 26.h,
                  width: 6.w,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(5.r),
                      bottom: Radius.circular(5.r),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  sectionTitle,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            SizedBox(
              height: 110.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: items,
              ),
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }





}

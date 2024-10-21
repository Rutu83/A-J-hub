import 'package:allinone_app/model/categories_subcategories_modal%20.dart';
import 'package:allinone_app/model/subcategory_model.dart';
import 'package:allinone_app/utils/shimmer/shimmer.dart';
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
  CategoriesWithSubcategoriesResponse? categoriesData;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    fetchCategoriesData();
    fetchSubcategoryData();
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
         //   _buildButtons(),
          //  const SizedBox(height: 10),
            _buildNewReleasesSection1(),
            const SizedBox(height: 10),
            _buildNewReleasesSection2(),
            isLoading ? _buildSkeletonLoading() : _buildContent(),
            const SizedBox(height: 120),
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


  // Widget _buildButtons() {
  //   return Card(
  //     color: Colors.white,
  //     elevation: 6,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     margin: const EdgeInsets.all(12),
  //     child: Container(
  //       padding: const EdgeInsets.all(12),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           _buildButtonColumn(Icons.person_add, 'Invite Friend'),
  //           _buildButtonColumn(Icons.card_giftcard, 'Membership'),
  //           _buildButtonColumn(Icons.info_outline, 'System Intro...'),
  //           InkWell(
  //             onTap: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => const CharityPage(),
  //                 ),
  //               );
  //             },
  //             child: _buildButtonColumn(Icons.business_sharp, 'Charity'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildButtonColumn(IconData icon, String label) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Container(
  //         height: 40.h, // Use a consistent height
  //         width: 40.h,  // Set width equal to height
  //         decoration: BoxDecoration(
  //           color: Colors.red,
  //           borderRadius: BorderRadius.circular(20.h), // Half of the height (20.h)
  //         ),
  //         child: Center( // Center the icon within the circle
  //           child: Icon(icon, color: Colors.white),
  //         ),
  //       ),
  //
  //
  //       const SizedBox(height: 8),
  //       Text(label),
  //     ],
  //   );
  // }

  // Single Card Layout Method with Optional Title
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

  // Single Card Layout Method with Optional Title
  Widget _buildCardItem2(String title, String imageUrl, List<String> images, {bool showTitle = true}) {
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
        //  border: Border.all(color: Colors.red.shade50),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(

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


  Widget _buildNewReleasesSection1() {
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
      return SizedBox(
        height: 100.h,
        child: Center(
          child: Text(
            'Failed to load data.',
            style: TextStyle(fontSize: 16.sp, color: Colors.red),
          ),
        ),
      );
    }

    List<Widget> items = [];
    String sectionTitle = 'Upcoming';
    var upcomingCategory = categoriesData!.categories.firstWhere(
          (category) => category.name.toLowerCase() == 'upcoming',
      orElse: () => CategoryWithSubcategory(name: 'No Upcoming', subcategories: []),
    );

    for (var subcategory in upcomingCategory.subcategories) {
      String imageUrl = subcategory.images.isNotEmpty ? subcategory.images[0] : 'assets/images/placeholder.jpg';
      items.add(
          _buildCardItem(subcategory.name, imageUrl, subcategory.images, showTitle: true));
    }

    return _buildHorizontalCardSection(sectionTitle: sectionTitle, items: items);
  }

  Widget _buildNewReleasesSection2() {
    if (isLoading) {
      return _buildSkeletonLoading();
    }

    if (hasError) {
      return Container();
    }

    if (categoriesData == null) {
      return Container();
    }

    List<Widget> items = [];
    String sectionTitle = 'Festival';

    var festivalCategory = categoriesData!.categories.firstWhere(
          (category) => category.name.toLowerCase() == 'festival',
      orElse: () => CategoryWithSubcategory(name: 'No Festival', subcategories: []),
    );

    for (var subcategory in festivalCategory.subcategories) {
      if (subcategory.images.isNotEmpty) {
        items.add(_buildCardItem2(subcategory.name, subcategory.images[0], subcategory.images, showTitle: false));
      }
    }

    return _buildHorizontalCardSection1(sectionTitle: sectionTitle, items: items);
  }

  Widget _buildHorizontalCardSection({required String sectionTitle, required List<Widget> items}) {
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


  Widget _buildHorizontalCardSection1({required String sectionTitle, required List<Widget> items}) {
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

  Widget _buildContent() {
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
          _buildSubcategorySections(),
        ],
      ),
    );
  }

  Widget _buildSubcategorySections() {
    List<Widget> sections = [];

    for (var subcategory in subcategoryData!.subcategories) {
      List<Widget> items = subcategory.images.map((imageUrl) {
        return _buildCardItem2(subcategory.name, imageUrl, subcategory.images, showTitle: false);
      }).toList();

      subcategory.images.map((imageUrl) {
        return {'image': imageUrl};
      }).toList();

      sections.add(_buildHorizontalCardSection1(
        sectionTitle: subcategory.name,
        items: items,
      ));
    }

    return Column(children: sections);
  }

}

import 'package:allinone_app/model/categories_subcategories_modal%20.dart';
import 'package:allinone_app/model/subcategory_model.dart';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:allinone_app/screens/category_selected.dart';
import 'package:allinone_app/screens/category_topics.dart';
import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  CustomerScreenState createState() => CustomerScreenState();
}

class CustomerScreenState extends State<CustomerScreen> with SingleTickerProviderStateMixin {
 // final FlutterAppAuth appAuth = const FlutterAppAuth();
  final String clientId = '000f55c4e8b5451bae4d7f099bc93a7a';
  final String redirectUri = 'https://ajsystem.in';
  final String clientSecret = 'c6113899241a471aa8dae63ac9f24b27';

  final List<String> scopes = ['user-library-read', 'user-read-email'];

  Future<SubcategoryResponse>? futureSubcategory;
  SubcategoryResponse? subcategoryData;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  late AnimationController _controller;
  late Animation<double> _animation;
  Future<List<CategoriesWithSubcategoriesResponse>>? futureCategories;
  CategoriesWithSubcategoriesResponse? categoriesData;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
      setState(() {});
    });

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(_controller);
    fetchSubcategoryData();
    fetchCategoriesData();
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchCategoriesData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await getCategoriesWithSubcategories();
      setState(() {
        categoriesData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        categoriesData = null;
        isLoading = false;
      });
      throw Exception('Failed to load categories data: $e');
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
        centerTitle: true,
        title: Text(
          'Category',
          style: GoogleFonts.roboto(
            fontSize: 18.0.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNewReleasesSection(),
            const SizedBox(height: 10),
            isLoading ? _buildSkeletonLoading() : _buildContent(),
            const SizedBox(height: 120),
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
        children: List.generate(5, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            child: Container(
              height: 130.h,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildSkeletonLoading(); // Show skeleton loader while loading
    }

    if (hasError) {
      return Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 200.h,
              width: 300.w,
              child: Lottie.asset('assets/animation/error_lottie.json'),
            ),
            Text(
              'No data found.',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (subcategoryData == null || subcategoryData!.subcategories.isEmpty) {
      return const SizedBox();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSubcategorySections(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }


  Widget _buildSubcategorySections() {
    List<Widget> sections = [];

    for (var subcategory in subcategoryData!.subcategories) {
      List<Widget> items = subcategory.images.map((imageUrl) {
        return _buildCardItem(
          subcategory.name,
          subcategory.plays,
          imageUrl,
          subcategory.images,
        );
      }).toList();

      List<Map<String, String>> topicMaps = subcategory.images.map((imageUrl) {
        return {
          'image': imageUrl,
        };
      }).toList();

      sections.add(
        _buildHorizontalCardSection(
          sectionTitle: subcategory.name,
          items: items,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryTopics(
                  title: subcategory.name,
                  images: topicMaps,
                ),
              ),
            );
          },
        ),
      );
    }

    return Column(
      children: sections,
    );
  }

  Widget _buildCardItem(String title, String plays, String imageUrl, List<String> allImages) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(imagePaths: allImages),
          ),
        );
      },
      child: SizedBox(
        width: 120.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 110.w,
              height: 100.h,
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
                      width: 110.w,
                      height: 100.h,
                      color: Colors.grey[300],
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCardSection({
    required String sectionTitle,
    required List<Widget> items,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 26.h,
                width: 4.w,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(5), bottom: Radius.circular(5)),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                sectionTitle,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              InkWell(
                onTap: onTap,
                child: Text('See All', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
              ),
              const Icon(Icons.arrow_right_outlined, color: Colors.grey, size: 25),
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
        ],
      ),
    );
  }

  Widget _buildNewReleasesSection() {
    if (isLoading) {
      return _buildSkeletonLoading(); // Use skeleton loader
    }

    if (categoriesData == null) {
      return const SizedBox.shrink(); // Return an empty widget if no data
    }

    var upcomingCategory = categoriesData!.categories.firstWhere(
          (category) => category.name.toLowerCase() == 'upcoming',
      orElse: () => CategoryWithSubcategory(name: 'No Upcoming', subcategories: []),
    );

    if (upcomingCategory.subcategories.isEmpty) {
      return const SizedBox.shrink(); // Return an empty widget if no subcategories
    }

    List<Widget> items = [];
    for (var subcategory in upcomingCategory.subcategories) {
      String imageUrl = subcategory.images.isNotEmpty
          ? subcategory.images[0]
          : 'assets/images/placeholder.jpg';

      items.add(_buildCardItem1(
        subcategory.name,
        imageUrl,
        subcategory.images,
      ));
    }

    return _buildHorizontalCardSection2(
      sectionTitle: 'Upcoming',
      items: items,
    );
  }




  Widget _buildCardItem1(String title, String imageUrl, List<String> images) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(imagePaths: images),
          ),
        );
      },
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(
        scale: _animation.value,
        child: Container(
          width: 101.w,
          margin: EdgeInsets.only(right: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                imageBuilder: (context, imageProvider) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.red.shade50, width: 2),
                  ),
                ),
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 90.w,
                  height: 90.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: const Icon(Icons.error, color: Colors.red),
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
      ),
    );
  }


  Widget _buildHorizontalCardSection2({required String sectionTitle, required List<Widget> items}) {
    if (items.isEmpty) {
      return const SizedBox.shrink(); // Return an empty widget if no items
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 26.h,
                width: 4.w,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(5),
                    bottom: Radius.circular(5),
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
    );
  }
}



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

            _buildUpcomingCategorySection(),
            _buildFestivalCategorySection(),


            const SizedBox(height: 10),
            isLoading ? _buildSkeletonLoading() : _buildContent(),
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
        children: List.generate(3, (index) {
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


  Widget _buildUpcomingCategorySection() {
    if (isLoading) {
      return _buildSkeletonLoading2();
    }

    if (hasError) {
      return const SizedBox(

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





  Widget _buildUpcomingHorizontalCard({required String sectionTitle, required List<Widget> items}) {
    return Padding(
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
    );
  }





  Widget _buildUpcomingCardItem(String title, String imageUrl, List<String> images, {bool showTitle = true}) {
    return InkWell(
      onTap: () {
        // Check if the image URL is valid and if the images list is not empty
        if (imageUrl.isEmpty || !imageUrl.startsWith('http') || images.isEmpty) {
          // Show error message when the data is invalid
          _showErrorMessage(context);
          return; // Prevent navigation to the next screen
        }

        // Proceed with navigation if data is valid
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(imagePaths: images,title: title),
          ),
        );
      },
      child: Container(
        width: 101.w,
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
                borderRadius: BorderRadius.circular(222.r), // Rounded corners
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(222.r),
                child: imageUrl.startsWith('http') // Check if imageUrl is a network URL
                    ? _buildNetworkImage(imageUrl)
                    : _buildAssetImage(imageUrl),
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

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorPlaceholder();
      },
    );
  }

  Widget _buildAssetImage(String path) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorPlaceholder();
      },
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey,
      child: const Icon(Icons.error, color: Colors.white),
    );
  }



  Widget _buildFestivalCategorySection() {
    if (isLoading) {
      return _buildSkeletonLoading3();
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
      // Check if images are available, else provide a default image
      String imageUrl = subcategory.images.isNotEmpty ? subcategory.images[0] : 'assets/images/default_festival.jpg';

      items.add(_buildCardFestival(subcategory.name, imageUrl, subcategory.images, showTitle: false));
    }

    return _buildHorizontalCardSection2(sectionTitle: sectionTitle, items: items);
  }
  Widget _buildCardFestival(String title, String imageUrl, List<String> images, {bool showTitle = true}) {
    return InkWell(
      onTap: () {
        // Check if the image URL is valid and if the images list is not empty
        if (imageUrl.isEmpty || !imageUrl.startsWith('http') || images.isEmpty) {
          // Show error message when the data is invalid
          _showErrorMessage(context);
          return; // Prevent navigation to the next screen
        }

        // Proceed with navigation if data is valid
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(imagePaths: images,title: title),
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
  void _showErrorMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Something went wrong. Cannot navigate to the next screen.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkeletonLoading3() {
    return Padding(padding: const EdgeInsets.only(left: 15,bottom: 10),
      child: SizedBox(
        height: 120.0,  // Height to match your card's height
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,  // Simulate 5 skeleton cards
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 120.0, // Width to match your card's width
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0), // Rounded corners like your card
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Skeleton for the image (image dimensions match your final card)
                      Container(
                        width: 120.0,
                        height: 90.0, // Image height matches the actual card
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0), // Match card's rounded corners
                          color: Colors.grey[200], // Light grey background for the skeleton image
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Skeleton for the title text
                      Container(
                        width: 80.0, // Title width
                        height: 14.0, // Title height
                        color: Colors.grey[200], // Light grey color for the text skeleton
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading2() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 10),
      child: SizedBox(
        height: 120.0,  // Height to match your card's height
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,  // Simulate 5 skeleton cards
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 120.0, // Width to match your card's width
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0), // Rounded corners for the container
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Skeleton for the circular image
                      Container(
                        width: 60.0,  // Circular shape: set width and height equal
                        height: 60.0, // Make sure it's equal to create a circle
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0), // Half of width/height for a circle
                          color: Colors.grey[200], // Light grey background for the skeleton image
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Skeleton for the title text
                      Container(
                        width: 80.0, // Title width
                        height: 14.0, // Title height
                        color: Colors.grey[200], // Light grey color for the text skeleton
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildHorizontalCardSection2({required String sectionTitle, required List<Widget> items}) {
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

    // Check if subcategoryData is null or empty
    if (subcategoryData == null || subcategoryData!.subcategories.isEmpty) {
      // Show an error message if no data exists
      _showErrorMessage(context);
      return const Center(
        child: Text('No subcategories available.'),
      );
    }

    for (var subcategory in subcategoryData!.subcategories) {
      List<Widget> items = subcategory.images.map((imageUrl) {
        return _buildCardItem2(
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
            // Only navigate if subcategory has data
            if (subcategory.images.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryTopics(
                    title: subcategory.name,
                    images: topicMaps,
                  ),
                ),
              );
            } else {
              // If images are empty, show a message
              _showErrorMessage(context);
            }
          },
        ),
      );
    }

    return Column(
      children: sections,
    );
  }
  Widget _buildCardItem2(String title, String plays, String imageUrl, List<String> allImages) {
    return InkWell(
      onTap: () {
        // Check if the image URL or allImages list is empty or null
        if (imageUrl.isEmpty || allImages.isEmpty) {
          _showErrorMessage(context);  // Show error message if data is missing
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategorySelected(imagePaths: allImages, title: title,),
            ),
          );
        }
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






 }



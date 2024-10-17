import 'package:allinone_app/model/categories_subcategories_modal%20.dart';
import 'package:allinone_app/model/subcategory_model.dart';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:allinone_app/screens/category_selected.dart';
import 'package:allinone_app/screens/category_topics.dart';
import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  CustomerScreenState createState() => CustomerScreenState();
}

class CustomerScreenState extends State<CustomerScreen> with SingleTickerProviderStateMixin {
  final FlutterAppAuth appAuth = const FlutterAppAuth();

  final String clientId = '000f55c4e8b5451bae4d7f099bc93a7a';
  final String redirectUri = 'https://ajsystem.in';
  final String clientSecret = 'c6113899241a471aa8dae63ac9f24b27';

  final List<String> scopes = ['user-library-read', 'user-read-email'];

  Future<SubcategoryResponse>? futureSubcategory;
  SubcategoryResponse? subcategoryData;
  bool isLoading = true; // State to manage loading
  bool hasError = false; // State to manage error
  String errorMessage = ''; // Error message to show in case of error

  Future<void> authenticate() async {
    final AuthorizationTokenResponse? result = await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        redirectUri,
        clientSecret: clientSecret,
        scopes: scopes,
      ),
    );

    if (result != null) {
      if (kDebugMode) {
        print('Access Token: ${result.accessToken}');
      }
      // Store the access token securely for future use
    }
  }
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
      final data = await getSubCategories(); // Fetch data from API
      setState(() {
        subcategoryData = data;

        if (kDebugMode) {
          print('....................$subcategoryData');
        }
        isLoading = false; // Stop loading once data is fetched
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Failed to load data: $e'; // Capture error message
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
      isLoading = true; // Set loading to true before fetching data
    });
    try {
      final data = await getCategoriesWithSubcategories();
      setState(() {
        categoriesData = data; // Store the fetched CategoriesWithSubcategoriesResponse
        isLoading = false; // Stop loading once data is fetched
      });
    } catch (e) {
      setState(() {
        categoriesData = null; // Ensure categoriesData is null on error
        isLoading = false; // Stop loading
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
    // Skeleton shimmer effect while loading data
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(5,
              (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Container(
              height: 130.h,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (hasError) {
      return Container(
        height: 200,
        width: 300,
        decoration: const BoxDecoration(
          //border: Border(top: BorderSide(color: Colors.grey.shade100))
        ),
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
          const SizedBox(
            height: 100,
          ),
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
          subcategory.images, // Pass the entire list of images here
        );
      }).toList();

      // Create a list of maps for topics
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
                  images: topicMaps, // Pass the list of maps
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
        // Pass the entire list of images instead of just the single image
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(imagePaths: allImages), // Pass all images
          ),
        );
      },
      child: Container(
        width: 145.w,
        margin: EdgeInsets.only(right: 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 130.w,
              height: 115.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r), // Optional: rounded corners
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: imageUrl.startsWith('assets/')
                    ? Image.asset(
                  imageUrl,
                  fit: BoxFit.fill,
                )
                    : Image.network(
                  imageUrl,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Modify the horizontal card section to accept the onTap parameter
  Widget _buildHorizontalCardSection({
    required String sectionTitle,
    required List<Widget> items,
    required VoidCallback onTap, // Add the onTap parameter
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 26,
                width: 4,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(5), bottom: Radius.circular(5)),
                ),
              ),
              const SizedBox(width: 8),
              Text(sectionTitle, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              const Spacer(),
              InkWell(
                onTap: onTap, // Use the onTap passed as a parameter
                child: Text('See All', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
              ),
              const Icon(Icons.arrow_right_outlined, color: Colors.grey, size: 25),
            ],
          ),
          SizedBox(height: 5.h),
          SizedBox(
            height: 105.h,
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
    // Check for loading state
    if (isLoading) {
      return _buildSkeletonLoader();
    }

    // Check if categoriesData is null or has errors
    if (categoriesData == null) {
      return  SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'Failed to load data.',
              style: TextStyle(fontSize: 16.sp, color: Colors.red),
            ),
          )
      );
    }

    List<Widget> items = [];
    String sectionTitle = 'Upcoming'; // Set the section title to 'Upcoming'

    // Find the upcoming category
    var upcomingCategory = categoriesData!.categories.firstWhere(
          (category) => category.name.toLowerCase() == 'upcoming',
      orElse: () => CategoryWithSubcategory(name: 'No Upcoming', subcategories: []),
    );

    // Add subcategories if the upcoming category is found
    for (var subcategory in upcomingCategory.subcategories) {
      String imageUrl = 'assets/images/placeholder.jpg'; // Default image

      // Get the first image from the subcategory's images
      if (subcategory.images.isNotEmpty) {
        imageUrl = subcategory.images[0]; // Use the first image URL if available
      }

      items.add(_buildCardItem1(
        subcategory.name,
        imageUrl, // Use the image URL from the subcategory
        subcategory.images, // Pass all images to the card item
      ));
    }

    return _buildHorizontalCardSection2(
      sectionTitle: sectionTitle,
      items: items,
    );
  }



  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 26,
                  width: 4,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(5),
                      bottom: Radius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 100.w,
                  height: 16.h,
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(height: 5.h),
            SizedBox(
              height: 120.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5, // Number of skeleton items
                itemBuilder: (context, index) {
                  return Container(
                    width: 101.w,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50.r), // Circular shape for skeleton
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
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
            builder: (context) => CategorySelected(imagePaths: images), // Pass all images
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
            // Add border here
            //border: Border.all(color: Colors.blueAccent, width: 2), // Adjust color and width as needed
            borderRadius: BorderRadius.circular(50.r), // Make it circular
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300), // Duration of the animation
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.shade50, width: 2), // Border for the circular image
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: 90.w, // Ensure width and height are equal for a circle
                    height: 90.w,
                    child: imageUrl.startsWith('http')
                        ? Image.network(
                           imageUrl,
                           fit: BoxFit.cover,
                           errorBuilder: (context, error, stackTrace) {
                             return Container(
                               color: Colors.grey, // Placeholder color
                               child: const Icon(Icons.error), // Error icon
                        );
                      },
                    )
                        : Image.asset(
                           imageUrl, // Load from assets
                           fit: BoxFit.cover,
                           errorBuilder: (context, error, stackTrace) {
                             return Container(
                               color: Colors.grey, // Placeholder color
                               child: const Icon(Icons.error), // Error icon
                        );
                      },
                    ),
                  ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 26,
                width: 4,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(5),
                    bottom: Radius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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




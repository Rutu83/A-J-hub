import 'package:allinone_app/model/categories_subcategories_modal%20.dart';
import 'package:allinone_app/model/subcategory_model.dart';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:allinone_app/screens/category_selected.dart';
import 'package:allinone_app/screens/category_topics.dart';
import 'package:allinone_app/screens/charity_screen.dart';
import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

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
  final FlutterAppAuth appAuth = const FlutterAppAuth();
  final String clientId = '000f55c4e8b5451bae4d7f099bc93a7a';
  final String redirectUri = 'https://ajsystem.in';
  final String clientSecret = 'c6113899241a471aa8dae63ac9f24b27';
  final List<String> scopes = ['user-library-read', 'user-read-email'];
  bool isLoading = true; // State to manage loading
  bool hasError = false; // State to manage error
  String errorMessage = ''; // Error message to show in case of error

  Future<SubcategoryResponse>? futureSubcategory;
  SubcategoryResponse? subcategoryData;

  Future<List<CategoriesWithSubcategoriesResponse>>? futureCategories;
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
  void dispose() {
    super.dispose();
  }

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
                    style: GoogleFonts.roboto(
                      fontSize: 16.0.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Good Morning',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.roboto(
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
            _buildButtons(),
            const SizedBox(height: 10),
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
                    return Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
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

  Widget _buildButtons() {
    return Card(
      color: Colors.white,
      elevation: 6, // Adds a shadow to give a card effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      margin: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(12), // Adds padding inside the card
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min, // Allows the column to have a uniform size
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(33), // Rounded corners
                  ),
                  child: const Icon(Icons.person_add, color: Colors.white),
                ),
                const SizedBox(height: 8), // Adds spacing between the icon and the text
                const Text('Invite Friend'),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(33), // Rounded corners
                  ),
                  child: const Icon(Icons.card_giftcard, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text('Membership'),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(33), // Rounded corners
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text('System Intro...'),
              ],
            ),

            InkWell(
              onTap: (){
                Navigator.push(context, (MaterialPageRoute(builder: (context)=>  const CharityPage())));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(33), // Rounded corners
                    ),
                    child: const Icon(Icons.business_sharp, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text('Charity'),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildNewReleasesSection1() {
    if (isLoading) {
      return _buildSkeletonLoader(); // Show skeleton while loading
    }

    if (hasError) {
      return SizedBox(
        height: 100,
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
        height: 100,
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

    // Find the upcoming category
    var upcomingCategory = categoriesData!.categories.firstWhere(
          (category) => category.name.toLowerCase() == 'upcoming',
      orElse: () => CategoryWithSubcategory(name: 'No Upcoming', subcategories: []),
    );

    // Add subcategories if found
    for (var subcategory in upcomingCategory.subcategories) {
      String imageUrl = subcategory.images.isNotEmpty ? subcategory.images[0] : 'assets/images/placeholder.jpg';

      items.add(_buildCardItem1(
        subcategory.name,
        imageUrl,
        subcategory.images,
      ));
    }

    return _buildHorizontalCardSection1(
      sectionTitle: sectionTitle,
      items: items,
    );
  }

  Widget _buildNewReleasesSection2() {
    if (isLoading) {
      return _buildSkeletonLoader(); // Show skeleton while loading
    }

    if (hasError) {
      return Container(); // or handle error message accordingly
    }

    if (categoriesData == null) {
      return Container();
    }

    List<Widget> items = [];
    String sectionTitle = 'Festival';

    // Find the festival category
    var festivalCategory = categoriesData!.categories.firstWhere(
          (category) => category.name.toLowerCase() == 'festival',
      orElse: () => CategoryWithSubcategory(name: 'No Festival', subcategories: []),
    );

    // Iterate through subcategories of the festival category
    for (var subcategory in festivalCategory.subcategories) {
      if (subcategory.images.isNotEmpty) {
        items.add(_buildCardItem3(
          subcategory.name,
          subcategory.images,
        ));
      }
    }

    return _buildHorizontalCardSection3(
      sectionTitle: sectionTitle,
      items: items,
    );
  }




  Widget _buildContent() {
    if (isLoading) {
      return _buildSkeletonLoading(); // Show skeleton loading when data is loading
    }

    if (hasError) {
      return Container(
        height: 200,
        width: 300,
        decoration: const BoxDecoration(
          //border: Border(top: BorderSide(color: Colors.grey.shade100))
        ),
        child: Lottie.asset('assets/animation/error_lottie.json'),
      );// Show skeleton loading when data is loading
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

  Widget _buildSubcategorySections() {
    List<Widget> sections = [];

    for (var subcategory in subcategoryData!.subcategories) {
      List<Widget> items = subcategory.images.map((imageUrl) {
        return _buildCardItem2(
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
        _buildHorizontalCardSection2(
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


  Widget _buildHorizontalCardSection3({required String sectionTitle, required List<Widget> items}) {
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
                width: 6,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(5), bottom: Radius.circular(5)),
                ),
              ),
              const SizedBox(width: 8),
              Text(sectionTitle, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),


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

// Modify the horizontal card section to accept the onTap parameter
  Widget _buildHorizontalCardSection2({required String sectionTitle, required List<Widget> items, required VoidCallback onTap, }) {
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
                width: 6,
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

  Widget _buildCardItem3(String title, List<String> images) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(imagePaths: images), // Pass all images
          ),
        );
      },
      child: Container(
        width: 100.w,
        margin: EdgeInsets.only(right: 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200), // Optional border
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: images.isNotEmpty
                    ? Image.network(
                  images[0], // Display the first image
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300, // Placeholder background
                      child: const Icon(Icons.error), // Fallback for errors
                    );
                  },
                )
                    : Image.asset(
                  'assets/images/placeholder.jpg',
                  fit: BoxFit.cover, // Use cover to fill the area
                ),
              ),
            ),

          ],
        ),
      ),
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
                      borderRadius: BorderRadius.circular(12.r), // Circular shape for skeleton
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(imagePaths: images), // Pass all images
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
              width: 90.w,
              height: 90.w,
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

  Widget _buildHorizontalCardSection1({required String sectionTitle, required List<Widget> items}) {
    return Container(
      color: const Color(0xFFFFF5F5),
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
                  width: 6,
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
      ),
    );
  }

  Widget _buildCardItem2(String title, String plays, String imageUrl, List<String> allImages) {
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


}



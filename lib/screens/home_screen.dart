import 'dart:convert';
import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/model/categories_subcategories_modal%20.dart';
import 'package:ajhub_app/model/daillyuse_modal.dart';
import 'package:ajhub_app/model/subcategory_model.dart';
import 'package:ajhub_app/screens/active_user_screen.dart';
import 'package:ajhub_app/screens/business_list.dart';
import 'package:ajhub_app/screens/category_topics.dart';
import 'package:ajhub_app/screens/charity_screen.dart';
import 'package:ajhub_app/screens/refer_earn.dart';
import 'package:ajhub_app/utils/configs.dart';
import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ajhub_app/screens/category_selected.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../network/rest_apis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  List<dynamic> businessData = [];
  int? selectedBusiness;
  List<String> _imageUrls = [];
  int _currentIndex = 0;
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


    fetchAllData();

  }

  @override
  void dispose() {

    super.dispose();
  }



  Future<void> fetchAllData() async {
    try {
      await Future.wait([
        fetchBusinessData(),
        _fetchBannerData(),
       fetchCategoriesData(),
        fetchSubcategoryData(),
        fetchDailyUseCategoryData(),
      ]);
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  Future<void> fetchBusinessData() async {
    const apiUrl = '${BASE_URL}getbusinessprofile';
    String token = appStore.token;

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];

        setState(() {
          businessData = data ?? [];
          isLoading = false;

          if (businessData.isNotEmpty) {
            final activeBusiness = businessData.firstWhere(
                  (business) => business['status'] == 'active',
              orElse: () => businessData.first,
            );

            selectedBusiness = activeBusiness['id'];
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('active_business', json.encode(activeBusiness));
            });
          } else {
            clearPreferences();
            selectedBusiness = null;
          }
        });
      } else if (response.statusCode == 404) {
        setState(() {
          businessData = [];
          isLoading = false;
        });
        await clearPreferences();
        selectedBusiness = null;
      } else {}
    } catch (e) {
      setState(() {
        isLoading = false;
        businessData = [];
      });
    }
  }

  Future<void> _fetchBannerData() async {
    const apiUrl = '${BASE_URL}getbanners';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          _imageUrls = List<String>.from(data.map((banner) => banner['banner_image_url']));
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
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
            backgroundImage: const AssetImage('assets/images/app_logo.png'),
            backgroundColor: Colors.red.shade50,
          ),
        ),

        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Welcome, ${appStore.Name}',
                    style: TextStyle(
                      fontSize: 14.0.sp,
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
                Icons.business_center_outlined,
                size: 22.0.sp,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  const BusinessList()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.notifications_active,
                size: 22.0.sp,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBannerSlider(),

            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6, top: 0, bottom: 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double buttonWidth = constraints.maxWidth / 4 - 12;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(context, Icons.share, 'Refer', buttonWidth, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReferEarn()),
                        );
                      }),
                      _buildButton(context, Icons.favorite, 'Charity', buttonWidth, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  const CharityScreen()),
                        );
                      }),
                      _buildButton(context, Icons.group, 'Community', buttonWidth, () {
                        openWhatsAppGroup(context);
                      }),
                      _buildButton(context, Icons.check_circle, 'Activation', buttonWidth, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ActiveUserPage()),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),


            _buildUpcomingCategorySection(),
            _buildImageBanner(),
            const SizedBox(height: 10),
            _buildFestivalCategorySection(),
            isLoading ? _buildSkeletonLoading() : _buildSubcategorySections(),
            const SizedBox(height: 10),
            _buildDailyUseSection(context,isLoading),

          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String label, double width, VoidCallback onPressed) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void openWhatsAppGroup(BuildContext context) async {
    const groupLink = "https://chat.whatsapp.com/K50pflHRu6EB1IXSpKOrbl"; // Your WhatsApp group link

    try {
      if (await canLaunch(groupLink)) {
        await launch(groupLink, forceSafariVC: false, forceWebView: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open WhatsApp group. Please ensure the app is installed.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  Widget _buildImageBanner() {
    return Padding(
      padding: EdgeInsets.only(left: 12.0.w, right: 12.0.w, top: 0, bottom: 0),
      child: InkWell(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReferEarn()),
          );
        },
        child: Center(
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              image: const DecorationImage(
                image: AssetImage('assets/images/banner3.jpg'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      )


    );
  }

  Widget _buildBannerSlider() {
    if (_imageUrls.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(8.0.w),
      );
    }

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
                      borderRadius: BorderRadius.circular(15.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(url),
                            fit: BoxFit.fill,
                            onError: (error, stackTrace) {},
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.fill,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: Colors.grey,),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        ),
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

  Widget _buildSkeletonLoading2() {
    return Padding(padding: const EdgeInsets.only(left: 15,bottom: 10),
    child: SizedBox(
      height: 150.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 120.0,
                margin: const EdgeInsets.only(right: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 120.0,
                      height: 90.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      width: 80.0,
                      height: 14.0,
                      color: Colors.grey[200],
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

  Widget _buildSkeletonLoading3() {
    return Padding(padding: const EdgeInsets.only(left: 15,bottom: 10),
      child: SizedBox(
        height: 120.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 120.0,
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 120.0,
                        height: 90.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.grey[200],    ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        width: 80.0,
                        height: 14.0,
                        color: Colors.grey[200],
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

  Widget _buildUpcomingCategorySection() {
    if (isLoading) {
      return _buildSkeletonLoading2();
    }

    if (hasError) {
      return const SizedBox(

      );
    }

    if (categoriesData == null) {
      return const SizedBox.shrink();
    }

    List<Widget> items = [];
    String sectionTitle = 'Upcoming';
    var upcomingCategory = categoriesData!.categories.firstWhere(
          (category) => category.name.toLowerCase() == 'upcoming',
      orElse: () => CategoryWithSubcategory(name: 'No Upcoming', subcategories: []),
    );

    if (upcomingCategory.subcategories.isEmpty) {
      return const SizedBox.shrink();
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
        if (imageUrl.isEmpty || !imageUrl.startsWith('http') || images.isEmpty) {
          _showErrorMessage(context);
          return;
        }

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
                image: imageUrl.startsWith('http')
                    ? DecorationImage(
                  image: CachedNetworkImageProvider(cacheKey:imageUrl ,imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                )
                    : DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: imageUrl.startsWith('http')
                    ? null
                    : Container(
                  color: Colors.grey,
                  child: const Icon(Icons.error),
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
      String imageUrl = subcategory.images.isNotEmpty ? subcategory.images[0] : 'assets/images/default_festival.jpg';

      items.add(_buildCardFestival(subcategory.name, imageUrl, subcategory.images, showTitle: false));
    }

    return _buildHorizontalCardSection(sectionTitle: sectionTitle, items: items, imageUrls: []);
  }

  Widget _buildCardFestival(String title, String imageUrl, List<String> images, {bool showTitle = true}) {
    return InkWell(
      onTap: () {
        if (imageUrl.isEmpty || !imageUrl.startsWith('http') || images.isEmpty) {
          _showErrorMessage(context);
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(imagePaths: images, title: title,),
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

  Widget _buildSubcategorySections() {
    if (isLoading) {
      return _buildSkeletonLoading();
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
      return const SizedBox();
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
      // Limit to 7 items (you can adjust this to 6 if needed)
      var limitedImages = subcategory.images.take(7).toList(); // Use 6 if you want 6 items instead

      List<Widget> items = limitedImages.map((imageUrl) {
        return _buildCardItem(subcategory.name, imageUrl, subcategory.images, showTitle: false);
      }).toList();

      // Creating a section with limited items
      sections.add(_buildHorizontalCardSection(
        sectionTitle: subcategory.name,
        items: items,
        imageUrls: limitedImages, // Pass imageUrls as well
      ));
    }

    return Column(children: sections);
  }

  Widget _buildSkeletonLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(2, (index) => Padding(
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

  Widget _buildHorizontalCardSection({required String sectionTitle, required List<Widget> items, required List<String> imageUrls,}) {
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
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    // Check if the items list is empty
                    if (items.isEmpty) {
                      _showErrorMessage(context); // Show error message if the list is empty
                      return;
                    }

                    // Extract image URLs from the items (if necessary) and navigate to CategorySelected
                    // In this case, we're using imageUrls, which can be passed to CategorySelected

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategorySelected(
                          imagePaths: imageUrls, // Pass the full list of imageUrls
                          title: sectionTitle,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: GoogleFonts.lato(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4), // Adds a small space between the text and icon
                      Icon(
                        CupertinoIcons.arrow_right_square_fill,
                        color: Colors.grey,
                        size: 16.sp,
                      ),
                    ],
                  ),
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
    );}

  Widget _buildCardItem(String title, String imageUrl, List<String> images, {bool showTitle = true}) {
    return InkWell(
      onTap: () {
        if (imageUrl.isEmpty || !imageUrl.startsWith('http') || images.isEmpty) {
          _showErrorMessage(context);
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(imagePaths: images, title: title,),
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

  Widget _buildDailyUseSection(BuildContext context, bool isLoading) {
    if (isLoading) {
      return _buildSkeletonLoadingForDailyUse(context);
    }
    List<Widget> items = [];
    if (daillyuseData != null && daillyuseData!.subcategories.isNotEmpty) {
      for (var category in daillyuseData!.subcategories) {
        String title = category.name;
        String imageUrl = category.images.isNotEmpty
            ? category.images[0]
            : 'assets/images/placeholder.jpg';

        // Convert List<String> to List<Map<String, String>>
        List<Map<String, String>> topicMaps =
        category.images.map((url) => {'image': url}).toList();

        items.add(_buildDailyUseItemCard(title, imageUrl, topicMaps, context));
      }
    }


    if (daillyuseData == null || daillyuseData!.subcategories.isEmpty) {
      return const SizedBox.shrink();
    }
    int crossAxisCount = 4;
    int rowCount = (items.length / crossAxisCount).ceil();
    double rowHeight = 120.h;
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
        if (topicMaps.isEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Topics Available'),
              content: const Text('There are no topics available to display. Please try again later.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          try {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryTopics(
                  title: title,
                  images: topicMaps,
                ),
              ),
            );
          } catch (e) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: const Text('An error occurred while navigating. Please try again later.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
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

  Widget _buildSkeletonLoadingForDailyUse(BuildContext context) {
    int crossAxisCount = 4;
    int skeletonItemCount = 8;

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
              height: 120.h * 2,
              child: GridView.builder(
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 15.h,
                  childAspectRatio: 0.80,
                ),
                itemCount: skeletonItemCount,
                itemBuilder: (context, index) {
                  return _buildSkeletonItem();
                },
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 80.w,
            height: 70.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 60.w,
            height: 10.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
      ],
    );
  }

}

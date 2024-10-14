import 'package:allinone_app/model/subcategory_model.dart';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:allinone_app/screens/category_selected.dart';
import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  CustomerScreenState createState() => CustomerScreenState();
}

class CustomerScreenState extends State<CustomerScreen> {
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

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    fetchSubcategoryData();
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
      body: isLoading ? _buildSkeletonLoading() : _buildContent(),
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
      return Center(
        child: Text(
          errorMessage,
          style: TextStyle(fontSize: 16.sp, color: Colors.red),
        ),
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
        return _buildCardItem2(
          subcategory.name,
          subcategory.plays,
          imageUrl,
        );
      }).toList();

      sections.add(
        _buildHorizontalCardSection1(
          sectionTitle: subcategory.name,
          items: items,
        ),
      );
    }

    return Column(
      children: sections,
    );
  }


  Widget _buildCardItem2(String title, String plays, String imageUrl) {
    return InkWell(
      onTap: () {
        // Define the list of images to show based on the title
        List<String> images = [imageUrl];

        // Navigate to the CategorySelected screen with the relevant images
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(imagePaths: images),
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

  Widget _buildHorizontalCardSection1({required String sectionTitle, required List<Widget> items}) {
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
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(5),
                    bottom: Radius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 8), // Add some spacing between the bar and the text
              Text(
                sectionTitle,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: 5.h),
          SizedBox(
            height: 130.h,
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

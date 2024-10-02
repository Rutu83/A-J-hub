import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
        title:  Text(
          'Custom',
          style: GoogleFonts.roboto(
            fontSize: 16.0.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(
              height: 40,
            ),
            _buildNewReleasesSection1(),

            _buildNewReleasesSection2(),

            _buildNewReleasesSection3(),

            _buildNewReleasesSection4(),

            const SizedBox(
              height: 150,
            )
          ],
        ),
      ),

    );
  }


  Widget _buildNewReleasesSection1() {
    return _buildHorizontalCardSection1(
      sectionTitle: 'Animated Videos',
      items: [
        _buildCardItem1('Gandhi Jayanti', '116M Plays', 'assets/images/gandhi_jayanti.jpg'),
        _buildCardItem1('Navratri Wishes', '25.9M Plays', 'assets/images/navratri_wishes.jpg'),
        _buildCardItem1('Hot Deal', '292.7M Plays', 'assets/images/hot_deal.png'),
        _buildCardItem1('Birthday', '9.4M Plays', 'assets/images/birthday.jpg'), // Using local asset
        _buildCardItem1('Hanuman Dada', '15.2M Plays', 'assets/images/hanuman_dada.jpg'),
        _buildCardItem1('Trending', '19.9M Plays', 'assets/images/trending.png'),
      ],
    );
  }


  Widget _buildNewReleasesSection2() {
    return _buildHorizontalCardSection(
      sectionTitle: 'Frame Store',
      items: [
        _buildCardItem('Hiss - Rebirth of a Destroyer', '116M Plays'),
        _buildCardItem('Maseeha Doctor', '25.9M Plays'),
        _buildCardItem('Shoorveer', '292.7M Plays'),
        _buildCardItem('The Guns of August', '9.4M Plays'),
        _buildCardItem('Hiroshima', '15.2M Plays'),
        _buildCardItem('The Histories', '19.9M Plays'),
      ],
    );
  }

  Widget _buildNewReleasesSection3() {
    return _buildHorizontalCardSection(
      sectionTitle: 'Winners of Navratri Events',
      items: [
        _buildCardItem('Hiss - Rebirth of a Destroyer', '116M Plays'),
        _buildCardItem('Maseeha Doctor', '25.9M Plays'),
        _buildCardItem('Shoorveer', '292.7M Plays'),
        _buildCardItem('The Guns of August', '9.4M Plays'),
        _buildCardItem('Hiroshima', '15.2M Plays'),
        _buildCardItem('The Histories', '19.9M Plays'),
      ],
    );
  }

  Widget _buildNewReleasesSection4() {
    return _buildHorizontalCardSection(
      sectionTitle: 'Marketing',
      items: [
        _buildCardItem('Hiss - Rebirth of a Destroyer', '116M Plays'),
        _buildCardItem('Maseeha Doctor', '25.9M Plays'),
        _buildCardItem('Shoorveer', '292.7M Plays'),
        _buildCardItem('The Guns of August', '9.4M Plays'),
        _buildCardItem('Hiroshima', '15.2M Plays'),
        _buildCardItem('The Histories', '19.9M Plays'),
      ],
    );
  }






  Widget _buildCardItem1(String title, String plays, String imageUrl) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: imageUrl.startsWith('assets/')
                  ? Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              )
                  : Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(String title, String plays) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12.r),
            ),

          ),
        ],
      ),
    );
  }


  Widget _buildHorizontalCardSection1({required String sectionTitle, required List<Widget> items,}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Vertical bar with rounded corners
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
              SizedBox(width: 8), // Add some spacing between the bar and the text
              // Section title
              Text(
                sectionTitle,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // "See All" text
              Text(
                'See All',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              // Arrow icon
              const Icon(
                Icons.arrow_right_outlined,
                color: Colors.grey,
                size: 25,
              ),
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


  Widget _buildHorizontalCardSection({required String sectionTitle, required List<Widget> items,}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Vertical bar with rounded corners
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
              SizedBox(width: 8), // Add some spacing between the bar and the text
              // Section title
              Text(
                sectionTitle,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // "See All" text
              Text(
                'See All',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              // Arrow icon
              const Icon(
                Icons.arrow_right_outlined,
                color: Colors.grey,
                size: 25,
              ),
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

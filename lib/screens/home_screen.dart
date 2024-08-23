
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _imageUrls = [
    'https://miro.medium.com/v2/resize:fit:1400/1*AxTSMdh-xZoluQ10nkqqrg.png',
    'https://image.cnbcfm.com/api/v1/image/107176545-1673363415079-gettyimages-1406724005-dsc01807.jpeg?v=1673505592&w=929&h=523&vtcrop=y',
    'https://cdn.phenompeople.com/CareerConnectResources/KIVKBRUS/images/MicrosoftTeams-image102[1920x927]web-1664813477508.jpg',
  ];

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

    return  Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        titleSpacing: 7.w,
        toolbarHeight: 60.h,
        leading: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: CircleAvatar(
            radius: 20.0.r,
            backgroundImage: const NetworkImage('https://miro.medium.com/v2/resize:fit:1400/1*AxTSMdh-xZoluQ10nkqqrg.png'),
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
            _buildTrendingSection(),
            // _buildRecommendedSection(),
            // _buildTopPicksSection(),
          ],
        ),
      ),
    );

  }

  Widget _buildTrendingSection() {
    return _buildHorizontalCardSection(
      sectionTitle: 'Trending This Week',
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

  // Widget _buildRecommendedSection() {
  //
  //
  //   return _buildHorizontalCardSection(
  //     sectionTitle: 'Because You Listened - Pyaar, Yaar Aur Dhokha',
  //     items: [
  //       _buildCardItem('The Guns of August', '9.4M Plays'),
  //       _buildCardItem('Hiroshima', '15.2M Plays'),
  //       _buildCardItem('The Histories', '19.9M Plays'),
  //     ],
  //   );
  // }
  //
  // Widget _buildTopPicksSection() {
  //   return _buildHorizontalCardSection(
  //     sectionTitle: 'Top Picks for Divya Bhachani',
  //     items: [
  //       _buildCardItem('Super Yoddha', '192M Plays'),
  //       _buildCardItem("Secret Ameezaada", ''),
  //     ],
  //   );
  // }

  Widget _buildHorizontalCardSection({required String sectionTitle, required List<Widget> items}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(sectionTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              const Spacer(flex: 1,),
              const Icon(Icons.arrow_forward_ios_rounded,color: Colors.grey,size: 20,)
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(String title, String plays) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,

            decoration: BoxDecoration(
                color: Colors.grey,
              borderRadius: BorderRadius.circular(12)
            ),
          ),
          // const SizedBox(height: 10),
          // Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          // Text(plays, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }


Widget _buildBannerSlider() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 150.0.h,
                autoPlay: true,
                viewportFraction: 1.0, // To show only one slide at a time without any scaling
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
                      width: MediaQuery.of(context).size.width, // Take up the full width
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
                margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? Colors.black
                      : Colors.grey,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

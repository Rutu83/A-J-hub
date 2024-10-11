import 'package:allinone_app/screens/category_selected.dart';
import 'package:allinone_app/screens/category_topics.dart';
import 'package:allinone_app/screens/charity_screen.dart';
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
    'https://cdn1.tripoto.com/media/filter/tst/img/2052077/Image/1695366505_main4.jpg.webp',
    'https://idolkart.com/cdn/shop/articles/What_happened_to_Krishna_s_body_after_death.jpg?v=1701867366&width=800',
    'https://indianexpress.com/wp-content/uploads/2019/01/netaji.jpg',
  ];
  final FlutterAppAuth appAuth = const FlutterAppAuth();
  final String clientId = '000f55c4e8b5451bae4d7f099bc93a7a';
  final String redirectUri = 'https://ajsystem.in';
  final String clientSecret = 'c6113899241a471aa8dae63ac9f24b27';
  final List<String> scopes = ['user-library-read', 'user-read-email'];

  @override
  void initState() {
    super.initState();
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


            _buildBanner('assets/images/banner.jpg'),
            const SizedBox(height: 10),
            _buildNewReleasesSection1(),
            const SizedBox(height: 10),
            _buildNewReleasesSection2(),
            _buildNewReleasesSection3(),
            _buildPostersSection(),
          ],
        ),
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
                Navigator.push(context, (MaterialPageRoute(builder: (context)=>  CharityPage())));
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


            // Container(
            //   height: 50,
            //   width: 50,
            //   decoration: BoxDecoration(
            //     color: Colors.red,
            //     borderRadius: BorderRadius.circular(33), // Rounded corners
            //   ),
            //   child: const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.white),
            // ),
          ],
        ),
      ),
    );
  }



  Widget _buildBanner(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r), // Rounded corners
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r), // Same border radius as the container
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
    );
  }




  Widget _buildNewReleasesSection1() {
    return _buildHorizontalCardSection1(
      sectionTitle: 'Upcoming Category',
      items: [
        _buildCardItem1('Gandhi Jayanti', '116M Plays', 'assets/images/gandhi_jayanti.jpg'),
        _buildCardItem1('Navratri Wishes', '25.9M Plays', 'assets/images/navratri_wishes.jpg'),
        _buildCardItem1('Birthday', '9.4M Plays', 'assets/images/birthday.jpg'),
        _buildCardItem1('Hanuman Dada', '15.2M Plays', 'assets/images/hanuman_dada.jpg'),
        _buildCardItem1('Trending', '19.9M Plays', 'assets/images/trending.png'),
      ],
    );
  }

  Widget _buildNewReleasesSection2() {
    return _buildHorizontalCardSection2(
      sectionTitle: 'Happy Navratri',
      items: [
        _buildCardItem3('Happy Navratri', '116M Plays', 'assets/images/navratri/navratri.jpg'),
        _buildCardItem3('Happy Navratri', '25.9M Plays', 'assets/images/navratri/navratri2.jpg'),
        _buildCardItem3('Happy Navratri', '292.7M Plays', 'assets/images/navratri/navratri3.jpg'),
        _buildCardItem3('Happy Navratri', '9.4M Plays', 'assets/images/navratri/navratri4.jpg'),
        _buildCardItem3('Happy Navratri', '15.2M Plays', 'assets/images/navratri/navratri5.jpg'),
        _buildCardItem3('Happy Navratri', '19.9M Plays', 'assets/images/navratri/navratri6.jpg'),
        _buildCardItem3('Happy Navratri', '19.9M Plays', 'assets/images/navratri/navratri7.jpg'),
        _buildCardItem3('Happy Navratri', '19.9M Plays', 'assets/images/navratri/navratri8.jpg'),
        _buildCardItem3('Happy Navratri', '19.9M Plays', 'assets/images/navratri/navratri9.jpg'),
        _buildCardItem3('Happy Navratri', '19.9M Plays', 'assets/images/navratri/navratri10.jpg'),
        _buildCardItem3('Happy Navratri', '19.9M Plays', 'assets/images/navratri/navratri11.jpg'),
        _buildCardItem3('Happy Navratri', '19.9M Plays', 'assets/images/navratri/navratri12.jpg'),
        _buildCardItem3('Happy Navratri', '19.9M Plays', 'assets/images/navratri/navratri13.jpg'),
        _buildCardItem3('Happy Navratri', '19.9M Plays', 'assets/images/navratri/navratri14.jpg'),
      ],
    );
  }

  Widget _buildNewReleasesSection3() {
    return _buildHorizontalCardSection2(
      sectionTitle: 'Quotes by Scientists',
      items: [
        _buildCardItem3('Quotes by Scientists', '116M Plays', 'assets/images/quotes/Quotes.jpg'),
        _buildCardItem3('Quotes by Scientists', '25.9M Plays', 'assets/images/quotes/Quotes2.jpg'),
        _buildCardItem3('Quotes by Scientists', '292.7M Plays', 'assets/images/quotes/Quotes3.jpg'),
        _buildCardItem3('Quotes by Scientists', '9.4M Plays', 'assets/images/quotes/Quotes4.jpg'),
        _buildCardItem3('Quotes by Scientists', '15.2M Plays', 'assets/images/quotes/Quotes5.jpg'),
        _buildCardItem3('Quotes by Scientists', '19.9M Plays', 'assets/images/quotes/Quotes6.jpg'),
        _buildCardItem3('Quotes by Scientists', '19.9M Plays', 'assets/images/quotes/Quotes7.jpg'),
        _buildCardItem3('Quotes by Scientists', '19.9M Plays', 'assets/images/quotes/Quotes8.jpg'),
        _buildCardItem3('Quotes by Scientists', '19.9M Plays', 'assets/images/quotes/Quotes9.jpg'),
        _buildCardItem3('Quotes by Scientists', '19.9M Plays', 'assets/images/quotes/Quotes10.jpg'),
        _buildCardItem3('Quotes by Scientists', '19.9M Plays', 'assets/images/quotes/Quotes11.jpg'),
        _buildCardItem3('Quotes by Scientists', '19.9M Plays', 'assets/images/quotes/Quotes12.jpg'),
        _buildCardItem3('Quotes by Scientists', '19.9M Plays', 'assets/images/quotes/Quotes13.jpg'),
      ],
    );
  }

  Widget _buildCardItem1(String title, String plays, String imageUrl) {
    return InkWell(
      onTap: () {
        // Define the list of images to show based on the title
        List<Map<String, String>> images;

        if (title == 'Gandhi Jayanti') {
          images = [
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji2.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji3.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji4.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji5.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji6.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji7.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji8.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji9.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji11.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji12.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji13.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji15.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji16.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji17.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji18.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji19.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji20.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji21.jpg'},
            {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji14.jpg'},
            // Add more images as needed
          ];
        } else if (title == 'Navratri Wishes') {
          images = [
            {'title': 'Navratri', 'image': 'assets/images/navratri/navratri.jpg'},
            {'title': 'Navratri', 'image': 'assets/images/navratri/navratri2.jpg'},
            {'title': 'Navratri', 'image': 'assets/images/navratri/navratri3.jpg'},
            {'title': 'Navratri', 'image': 'assets/images/navratri/navratri4.jpg'},
            {'title': 'Navratri', 'image': 'assets/images/navratri/navratri5.jpg'},
            {'title': 'Navratri', 'image': 'assets/images/navratri/navratri6.jpg'},
            {'title': 'Navratri', 'image': 'assets/images/navratri/navratri7.jpg'},
            {'title': 'Navratri', 'image': 'assets/images/navratri/navratri8.jpg'},
            {'title': 'Navratri', 'image': 'assets/images/navratri/navratri9.jpg'},
            {'title': 'Navratri', 'image': 'assets/images/navratri/navratri10.jpg'},
            {'title': 'Navratri', 'image': 'assets/images/navratri/navratri11.jpg'},
            {'title': 'Navratri', 'image': 'assets/images/navratri/navratri12.jpg'},
            {'title': 'Navratri', 'image': 'assets/images/navratri/navratri13.jpg'},
            // Add more images as needed
          ];
        }  else if (title == 'Birthday') {
          images = [
            {'title': 'Birthday', 'image': 'assets/images/birthday/birthday.jpg'},
            {'title': 'Birthday', 'image': 'assets/images/birthday/birthday2.jpg'},
            {'title': 'Birthday', 'image': 'assets/images/birthday/birthday3.jpg'},
            {'title': 'Birthday', 'image': 'assets/images/birthday/birthday4.jpg'},
            {'title': 'Birthday', 'image': 'assets/images/birthday/birthday5.jpg'},
            {'title': 'Birthday', 'image': 'assets/images/birthday/birthday6.jpg'},
            {'title': 'Birthday', 'image': 'assets/images/birthday/birthday7.jpg'},
            {'title': 'Birthday', 'image': 'assets/images/birthday/birthday8.jpg'},
            {'title': 'Birthday', 'image': 'assets/images/birthday/birthday9.jpg'},
            {'title': 'Birthday', 'image': 'assets/images/birthday/birthday10.jpg'},
            {'title': 'Birthday', 'image': 'assets/images/birthday/birthday11.jpg'},
            {'title': 'Birthday', 'image': 'assets/images/birthday/birthday12.jpg'},
            // Add more images as needed
          ];
        }  else if (title == 'Hanuman Dada') {
          images = [
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman1.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman2.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman3.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman4.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman5.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman6.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman7.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman8.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman9.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman10.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman11.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman12.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman13.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman14.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman9.jpg'},
            {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman10.jpg'},
            // Add more images as needed
          ];
        }else {
          images = []; // Default empty list if no matching title
        }

        // Navigate to the CategoryTopics screen with the relevant images
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryTopics(
              title: title,
              topics: images,
            ),
          ),
        );
      },
      child: Container(
        width: 100.w,
        margin: EdgeInsets.only(right: 10.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.shade50),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
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

  Widget _buildHorizontalCardSection2({required String sectionTitle, required List<Widget> items}) {
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
              const SizedBox(width: 8),
              Text(
                sectionTitle,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  // Define the list of images to show based on the title
                  List<Map<String, String>> images;

                  if (sectionTitle == 'Quotes by Scientists') {
                    images = [
                      {'title': 'Quotes by Scientists', 'image': 'assets/images/quotes/Quotes.jpg'},
                      {'title': 'Quotes by Scientists', 'image': 'assets/images/quotes/Quotes2.jpg'},
                      {'title': 'Quotes by Scientists', 'image': 'assets/images/quotes/Quotes3.jpg'},
                      {'title': 'Quotes by Scientists', 'image': 'assets/images/quotes/Quotes4.jpg'},
                      {'title': 'Quotes by Scientists', 'image': 'assets/images/quotes/Quotes5.jpg'},
                      {'title': 'Quotes by Scientists', 'image': 'assets/images/quotes/Quotes6.jpg'},
                      {'title': 'Quotes by Scientists', 'image': 'assets/images/quotes/Quotes7.jpg'},
                      {'title': 'Quotes by Scientists', 'image': 'assets/images/quotes/Quotes8.jpg'},
                      {'title': 'Quotes by Scientists', 'image': 'assets/images/quotes/Quotes9.jpg'},
                      {'title': 'Quotes by Scientists', 'image': 'assets/images/quotes/Quotes10.jpg'},
                      {'title': 'Quotes by Scientists', 'image': 'assets/images/quotes/Quotes11.jpg'},
                      {'title': 'Quotes by Scientists', 'image': 'assets/images/quotes/Quotes12.jpg'},
                      {'title': 'Quotes by Scientists', 'image': 'assets/images/quotes/Quotes13.jpg'},

                      // Add more images as needed
                    ];
                  } else if (sectionTitle == 'Happy Navratri') {
                    images = [
                      {'title': 'Navratri', 'image': 'assets/images/navratri/navratri.jpg'},
                      {'title': 'Navratri', 'image': 'assets/images/navratri/navratri2.jpg'},
                      {'title': 'Navratri', 'image': 'assets/images/navratri/navratri3.jpg'},
                      {'title': 'Navratri', 'image': 'assets/images/navratri/navratri4.jpg'},
                      {'title': 'Navratri', 'image': 'assets/images/navratri/navratri5.jpg'},
                      {'title': 'Navratri', 'image': 'assets/images/navratri/navratri6.jpg'},
                      {'title': 'Navratri', 'image': 'assets/images/navratri/navratri7.jpg'},
                      {'title': 'Navratri', 'image': 'assets/images/navratri/navratri8.jpg'},
                      {'title': 'Navratri', 'image': 'assets/images/navratri/navratri9.jpg'},
                      {'title': 'Navratri', 'image': 'assets/images/navratri/navratri10.jpg'},
                      {'title': 'Navratri', 'image': 'assets/images/navratri/navratri11.jpg'},
                      {'title': 'Navratri', 'image': 'assets/images/navratri/navratri12.jpg'},
                      {'title': 'Navratri', 'image': 'assets/images/navratri/navratri13.jpg'},
                      // Add more images as needed
                    ];
                  }   else {
                    images = []; // Default empty list if no matching title
                  }

                  // Navigate to the CategoryTopics screen with the relevant images
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryTopics(
                        title: sectionTitle,
                        topics: images,
                      ),
                    ),
                  );
                },
                child: Text(
                  'See All',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              ),
              const Icon(
                Icons.arrow_right_outlined,
                color: Colors.grey,
                size: 25,
              ),
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

  Widget _buildPostersSection() {
    return _buildHorizontalCardSection(
      sectionTitle: 'Poster',
      items: [
        _buildCardItem2('Hiss - Rebirth of a Destroyer', '116M Plays', 'assets/images/poster/poster1.jpg'),
        _buildCardItem2('Maseeha Doctor', '25.9M Plays', 'assets/images/poster/poster2.jpg'),
        _buildCardItem2('Shoorveer', '292.7M Plays', 'assets/images/poster/poster3.jpg'),
      ],
    );
  }

  Widget _buildHorizontalCardSection({required String sectionTitle, required List<Widget> items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(sectionTitle, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              const Spacer(flex: 1),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 20),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 200.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem2(String title, String plays, String imagePath) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }


  Widget _buildCardItem3(String title, String plays, String imageUrl) {
    return InkWell(
      onTap: () {
        // Define the list of images to show based on the title
        List<String> images;

        if (title == 'Happy Navratri') {
          images = [
            'assets/images/navratri/navratri.jpg',
            'assets/images/navratri/navratri2.jpg',
            'assets/images/navratri/navratri3.jpg',
            'assets/images/navratri/navratri4.jpg',
            'assets/images/navratri/navratri5.jpg',
            'assets/images/navratri/navratri6.jpg',
            'assets/images/navratri/navratri7.jpg',
            'assets/images/navratri/navratri8.jpg',
            'assets/images/navratri/navratri9.jpg',
            'assets/images/navratri/navratri10.jpg',
            'assets/images/navratri/navratri11.jpg',
            'assets/images/navratri/navratri12.jpg',
            'assets/images/navratri/navratri13.jpg',
            'assets/images/navratri/navratri14.jpg',
          ];
        } else if (title == 'Quotes by Scientists') {
          images = [
            'assets/images/quotes/Quotes.jpg',
            'assets/images/quotes/Quotes2.jpg',
            'assets/images/quotes/Quotes3.jpg',
            'assets/images/quotes/Quotes4.jpg',
            'assets/images/quotes/Quotes5.jpg',
            'assets/images/quotes/Quotes6.jpg',
            'assets/images/quotes/Quotes7.jpg',
            'assets/images/quotes/Quotes.jpg',
            'assets/images/quotes/Quotes9.jpg',
            'assets/images/quotes/Quotes10.jpg',
            'assets/images/quotes/Quotes11.jpg',
            'assets/images/quotes/Quotes12.jpg',
            'assets/images/quotes/Quotes13.jpg',

          ];
        } else {
          images = []; // Default empty list if no matching title
        }

        // Navigate to the CategorySelected screen with the relevant images
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(imagePaths: images),
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
}

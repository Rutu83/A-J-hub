import 'package:allinone_app/screens/category_selected.dart';
import 'package:allinone_app/screens/category_topics.dart';
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
          'Category',
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

            _buildNewReleasesSection5(),

            _buildNewReleasesSection6(),

            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),

    );
  }




  Widget _buildNewReleasesSection2() {
    return _buildHorizontalCardSection2(
      sectionTitle: 'Farm store',
      items: [
        _buildCardItem2('Farm store', '116M Plays',   'assets/images/framstore/framstore.jpg'),
        _buildCardItem2('Farm store', '25.9M Plays',   'assets/images/framstore/framstore2.jpg'),
        _buildCardItem2('Farm store', '292.7M Plays',  'assets/images/framstore/framstore3.jpg'),
        _buildCardItem2('Farm store', '9.4M Plays',    'assets/images/framstore/framstore4.jpg'), // Using local asset
        _buildCardItem2('Farm store', '15.2M Plays',  'assets/images/framstore/framstore5.jpg'),
        _buildCardItem2('Farm store', '19.9M Plays',  'assets/images/framstore/framstore6.jpg'),
        _buildCardItem2('Farm store', '19.9M Plays',  'assets/images/framstore/framstore7.jpg'),
        _buildCardItem2('Farm store', '19.9M Plays', 'assets/images/framstore/framstore8.jpg'),
        _buildCardItem2('Farm store', '19.9M Plays', 'assets/images/framstore/framstore9.jpg'),
        _buildCardItem2('Farm store', '19.9M Plays', 'assets/images/framstore/framstore10.jpg'),
        _buildCardItem2('Farm store', '19.9M Plays', 'assets/images/framstore/framstore11.jpg'),
        _buildCardItem2('Farm store', '19.9M Plays', 'assets/images/framstore/framstore12.jpg'),
        _buildCardItem2('Farm store', '19.9M Plays', 'assets/images/framstore/framstore13.jpg'),
        _buildCardItem2('Farm store', '19.9M Plays', 'assets/images/framstore/framstore14.jpg'),
      ],
    );
  }

  Widget _buildNewReleasesSection3() {
    return _buildHorizontalCardSection2(
      sectionTitle: 'Mahadev',
      items: [
        _buildCardItem2('Mahadev', '116M Plays', 'assets/images/shiv/shiv.jpg'    ),
        _buildCardItem2('Mahadev', '25.9M Plays', 'assets/images/shiv/shiv2.jpg'       ),
        _buildCardItem2('Mahadev', '292.7M Plays','assets/images/shiv/shiv3.jpg'        ),
        _buildCardItem2('Mahadev', '9.4M Plays', 'assets/images/shiv/shiv4.jpg'     ), // Using local asset
        _buildCardItem2('Mahadev', '15.2M Plays', 'assets/images/shiv/shiv5.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv6.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv7.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv8.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv9.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv10.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv11.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv12.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv13.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv14.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv15.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv16.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv17.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv18.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv19.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv20.jpg'),
        _buildCardItem2('Mahadev', '19.9M Plays', 'assets/images/shiv/shiv21.jpg'),
      ],
    );
  }

  Widget _buildNewReleasesSection4() {
    return _buildHorizontalCardSection2(
      sectionTitle: 'Marketing',
      items: [
        _buildCardItem2('Marketing', '116M Plays', 'assets/images/Marketing/Marketing.jpg'),
        _buildCardItem2('Marketing', '25.9M Plays', 'assets/images/Marketing/Marketing2.jpg'),
        _buildCardItem2('Marketing', '292.7M Plays', 'assets/images/Marketing/Marketing3.jpg'),
        _buildCardItem2('Marketing', '9.4M Plays', 'assets/images/Marketing/Marketing4.jpg'), // Using local asset
        _buildCardItem2('Marketing', '15.2M Plays', 'assets/images/Marketing/Marketing5.jpg'),
        _buildCardItem2('Marketing', '19.9M Plays', 'assets/images/Marketing/Marketing6.jpg'),
        _buildCardItem2('Marketing', '19.9M Plays', 'assets/images/Marketing/Marketing7.jpg'),
        _buildCardItem2('Marketing', '19.9M Plays', 'assets/images/Marketing/Marketing8.jpg'),
      ],
    );
  }

  Widget _buildNewReleasesSection5() {
    return _buildHorizontalCardSection2(
      sectionTitle: 'Anniversary',
      items: [
        _buildCardItem2('Anniversary', '116M Plays', 'assets/images/anniversary/anniversary.jpg'),
        _buildCardItem2('Anniversary', '25.9M Plays', 'assets/images/anniversary/anniversary2.jpg'),
        _buildCardItem2('Anniversary', '292.7M Plays', 'assets/images/anniversary/anniversary3.jpg'),
        _buildCardItem2('Anniversary', '9.4M Plays', 'assets/images/anniversary/anniversary4.jpg'), // Using local asset
        _buildCardItem2('Anniversary', '15.2M Plays', 'assets/images/anniversary/anniversary5.jpg'),
        _buildCardItem2('Anniversary', '19.9M Plays', 'assets/images/anniversary/anniversary6.jpg'),
      ],
    );
  }


  Widget _buildNewReleasesSection6() {
    return _buildHorizontalCardSection2(
      sectionTitle: 'fligth',
      items: [
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f2.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f3.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f4.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f5.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f6.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f7.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f8.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f9.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f10.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f11.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f12.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f13.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f14.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f15.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f16.jpg'),
        _buildCardItem2('fligth', '116M Plays', 'assets/images/fligth/f17.jpg'),
      ],
    );
  }

  Widget _buildCardItem2(String title, String plays, String imageUrl) {
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
        } else if (title == 'Farm store') {
          images = [
               'assets/images/framstore/framstore.jpg',
                'assets/images/framstore/framstore2.jpg',
                'assets/images/framstore/framstore3.jpg',
                'assets/images/framstore/framstore4.jpg',
               'assets/images/framstore/framstore5.jpg',
               'assets/images/framstore/framstore6.jpg',
               'assets/images/framstore/framstore7.jpg',
              'assets/images/framstore/framstore8.jpg',
              'assets/images/framstore/framstore9.jpg',
              'assets/images/framstore/framstore10.jpg',
              'assets/images/framstore/framstore11.jpg' ,
              'assets/images/framstore/framstore12.jpg' ,
              'assets/images/framstore/framstore13.jpg' ,
              'assets/images/framstore/framstore14.jpg',
          ];
        } else if (title == 'Mahadev') {
          images = [
          'assets/images/shiv/shiv.jpg',
           'assets/images/shiv/shiv2.jpg',
          'assets/images/shiv/shiv3.jpg',
          'assets/images/shiv/shiv4.jpg',
           'assets/images/shiv/shiv5.jpg',
           'assets/images/shiv/shiv6.jpg',
           'assets/images/shiv/shiv7.jpg',
           'assets/images/shiv/shiv8.jpg',
           'assets/images/shiv/shiv9.jpg',
           'assets/images/shiv/shiv10.jpg',
           'assets/images/shiv/shiv11.jpg',
           'assets/images/shiv/shiv12.jpg',
           'assets/images/shiv/shiv13.jpg',
           'assets/images/shiv/shiv14.jpg' ,
          ];
        } else if (title == 'Marketing') {
          images = [
            'assets/images/Marketing/Marketing.jpg',
             'assets/images/Marketing/Marketing2.jpg',
             'assets/images/Marketing/Marketing3.jpg',
            'assets/images/Marketing/Marketing4.jpg',
             'assets/images/Marketing/Marketing5.jpg',
             'assets/images/Marketing/Marketing6.jpg',
             'assets/images/Marketing/Marketing7.jpg',
             'assets/images/Marketing/Marketing8.jpg',

          ];
        } else if (title == 'Anniversary') {
          images = [
            'assets/images/anniversary/anniversary.jpg',
            'assets/images/anniversary/anniversary2.jpg',
            'assets/images/anniversary/anniversary3.jpg',
            'assets/images/anniversary/anniversary4.jpg',
            'assets/images/anniversary/anniversary5.jpg',
            'assets/images/anniversary/anniversary6.jpg',

          ];
        } else if (title == 'fligth') {
          images = [
            'assets/images/fligth/f.jpg',
            'assets/images/fligth/f2.jpg',
            'assets/images/fligth/f3.jpg',
            'assets/images/fligth/f4.jpg',
            'assets/images/fligth/f5.jpg',
            'assets/images/fligth/f6.jpg',
            'assets/images/fligth/f7.jpg',
            'assets/images/fligth/f8.jpg',
            'assets/images/fligth/f9.jpg',
            'assets/images/fligth/f10.jpg',
            'assets/images/fligth/f11.jpg',
            'assets/images/fligth/f12.jpg',
            'assets/images/fligth/f13.jpg',
            'assets/images/fligth/f14.jpg',
            'assets/images/fligth/f15.jpg',
            'assets/images/fligth/f16.jpg',
            'assets/images/fligth/f17.jpg',

          ];
        }else {
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
        width: 160.w,
        margin: EdgeInsets.only(right: 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 140.w,
              height: 121.w,
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

  Widget _buildHorizontalCardSection2({required String sectionTitle, required List<Widget> items,}) {
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
              const SizedBox(width: 8), // Add some spacing between the bar and the text
              // Section title
              Text(
                sectionTitle,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // "See All" text

              InkWell(
                onTap: () {
                  // Define the list of images to show based on the title
                  List<Map<String, String>> images;

                  if (sectionTitle == 'Happy Navratri') {

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
                  }   else if (sectionTitle == 'Farm store') {

                    images = [
                      {'title': 'Farm store', 'image': 'assets/images/framstore/framstore.jpg'},
                      {'title': 'Farm store', 'image': 'assets/images/framstore/framstore2.jpg'},
                      {'title': 'Farm store', 'image': 'assets/images/framstore/framstore3.jpg'},
                      {'title': 'Farm store', 'image': 'assets/images/framstore/framstore4.jpg'},
                      {'title': 'Farm store', 'image': 'assets/images/framstore/framstore5.jpg'},
                      {'title': 'Farm store', 'image': 'assets/images/framstore/framstore6.jpg'},
                      {'title': 'Farm store', 'image': 'assets/images/framstore/framstore7.jpg'},
                      {'title': 'Farm store', 'image': 'assets/images/framstore/framstore8.jpg'},
                      {'title': 'Farm store', 'image': 'assets/images/framstore/framstore9.jpg'},
                      {'title': 'Farm store', 'image': 'assets/images/framstore/framstore10.jpg'},
                      {'title': 'Farm store', 'image': 'assets/images/framstore/framstore11.jpg'},
                      {'title': 'Farm store', 'image': 'assets/images/framstore/framstore12.jpg'},
                      {'title': 'Farm store', 'image': 'assets/images/framstore/framstore13.jpg'},
                      // Add more images as needed
                    ];
                  }   else if (sectionTitle == 'Mahadev') {

                    images = [
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv.jpg'},
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv2.jpg'},
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv3.jpg'},
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv4.jpg'},
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv5.jpg'},
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv6.jpg'},
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv7.jpg'},
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv8.jpg'},
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv9.jpg'},
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv10.jpg'},
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv11.jpg'},
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv12.jpg'},
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv13.jpg'},
                      {'title': 'Mahadev', 'image': 'assets/images/shiv/shiv14.jpg'},
                      // Add more images as needed
                    ];
                  }    else if (sectionTitle == 'Marketing') {

                    images = [
                      {'title': 'Marketing', 'image': 'assets/images/Marketing/Marketing.jpg'},
                      {'title': 'Marketing', 'image': 'assets/images/Marketing/Marketing2.jpg'},
                      {'title': 'Marketing', 'image': 'assets/images/Marketing/Marketing3.jpg'},
                      {'title': 'Marketing', 'image': 'assets/images/Marketing/Marketing4.jpg'},
                      {'title': 'Marketing', 'image': 'assets/images/Marketing/Marketing5.jpg'},
                      {'title': 'Marketing', 'image': 'assets/images/Marketing/Marketing6.jpg'},
                      {'title': 'Marketing', 'image': 'assets/images/Marketing/Marketing7.jpg'},
                      {'title': 'Marketing', 'image': 'assets/images/Marketing/Marketing8.jpg'},
                      // Add more images as needed
                    ];
                  }   else if (sectionTitle == 'Anniversary') {

                    images = [
                      {'title': 'Anniversary', 'image': 'assets/images/anniversary/anniversary.jpg'},
                      {'title': 'Anniversary', 'image': 'assets/images/anniversary/anniversary2.jpg'},
                      {'title': 'Anniversary', 'image': 'assets/images/anniversary/anniversary3.jpg'},
                      {'title': 'Anniversary', 'image': 'assets/images/anniversary/anniversary4.jpg'},
                      {'title': 'Anniversary', 'image': 'assets/images/anniversary/anniversary5.jpg'},
                      {'title': 'Anniversary', 'image': 'assets/images/anniversary/anniversary6.jpg'},
                      // Add more images as needed
                    ];
                  }else if (sectionTitle == 'fligth') {

                    images = [
                      {'title': 'fligth', 'image': 'assets/images/fligth/f.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f2.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f3.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f4.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f5.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f6.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f7.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f8.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f9.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f10.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f11.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f12.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f13.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f14.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f15.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f16.jpg'},
                      {'title': 'fligth', 'image': 'assets/images/fligth/f17.jpg'},
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
                        title: sectionTitle,
                        topics: images,
                      ),
                    ),
                  );
                },
                child:   Text(
                  'See All',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
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
            height: 120.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: items,
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
              const SizedBox(width: 8), // Add some spacing between the bar and the text
              // Section title
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


  Widget _buildNewReleasesSection1() {
    return _buildHorizontalCardSection1(
      sectionTitle: 'Trending Topics',
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

  Widget _buildCardItem1(String title, String plays, String imageUrl) {

    return  InkWell(
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
      ),
    );

  }
}

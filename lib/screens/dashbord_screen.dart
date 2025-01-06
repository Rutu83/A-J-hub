import 'package:allinone_app/network/rest_apis.dart';
import 'package:allinone_app/screens/active_user_screen2.dart';
import 'package:allinone_app/screens/product_and_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:allinone_app/screens/business_screen.dart';
import 'package:allinone_app/screens/home_screen.dart';
import 'package:allinone_app/screens/oportunity.dart';
import 'package:allinone_app/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;





  @override
  void initState() {
    super.initState();

    fetchUserData();

   }


  void fetchUserData() async {
    try {
      Map<String, dynamic> userDetail = await getUserDetail();
      if (kDebugMode) {
        print('...........................................................');
        print(userDetail);
      }

      // Check if the status is 'active' or 'inactive'
      String status = userDetail['status'] ?? ''; // Get status from the response
      if (status == 'inactive') {
        // If status is 'inactive', show the activation dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showActivationDialog();
        });
      } else {
        // If status is 'active', print the status
        if (kDebugMode) {
          print('////////////////////////////////$status');
        }
      }

      // Store user details as variables


    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children:  const [
            HomeScreen(),
            OportunityScreen(),
           // CustomerScreen(),
            OurProductAndService(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: EdgeInsets.only(bottom: 8.h),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMenuItem(Icons.home, "Home", 0),
                SizedBox(width: 20.w),
                _buildMenuItem(Icons.card_giftcard, "Opportunity", 1),

                SizedBox(width: 20.w),
                // BusinessScreen(),
                GestureDetector(
                  onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const BusinessScreen()));
                  },
                  child: Container(
                    height: 70.h,
                    width: 70.h,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(35.h),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/aj_logo_white.png',
                        height: 70.h,
                        width: 70.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                _buildMenuItem(Icons.business, "Branding", 2),

                SizedBox(width: 20.w),
                _buildMenuItem(Icons.account_circle, "Account", 3),  // Account tab

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActivationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing the dialog by tapping outside
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Make background transparent
          child: Stack(
            children: [
              // GestureDetector to navigate on image click
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ActivateMembershipPage()), // Navigate to the ActivateMembershipPage
                  ).then((_) {
                    Navigator.pop(context); // Pop dialog when navigating back
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0), // Increased border radius
                  child: Image.asset(
                    'assets/images/offers/or.jpg', // Your image asset path
                    width: MediaQuery.of(context).size.width * 0.8, // Adjust width based on screen width
                    height: MediaQuery.of(context).size.height * 0.5, // Increased height
                    fit: BoxFit.cover, // Adjust the fit to cover the area
                  ),
                ),
              ),
              // Close button (cross icon) at the top-right corner with background
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close the dialog when tapped
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6), // Padding around the icon
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5), // Background color for the close icon
                      borderRadius: BorderRadius.circular(20), // Rounded background for the icon
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white, // White color for the close icon
                      size: 15, // Size of the close icon
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }







  Widget _buildMenuItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _pageController.jumpToPage(index);
      },
      child: SizedBox(
        height: 50.h, // Adjusted size to ensure proper display
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28.sp, // Adjust size with ScreenUtil
              color: _selectedIndex == index ? Colors.red : Colors.grey,
            ),
            SizedBox(height: 4.h), // Adjust with ScreenUtil
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp, // Adjust font size with ScreenUtil
                color: _selectedIndex == index ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

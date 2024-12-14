import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:allinone_app/screens/business_screen.dart';
import 'package:allinone_app/screens/customer_screen.dart';
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
          children: const [
            HomeScreen(),
            OportunityScreen(),
            CustomerScreen(),
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
                        'assets/images/aj2.jpg',
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

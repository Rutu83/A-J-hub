import 'package:allinone_app/screens/home_screen.dart';
import 'package:allinone_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // Replace these placeholders with your actual screen widgets
    const HomeScreen(),
    const Center(child: Text('Favorites Screen')),
    const Center(child: Text('Search Screen')),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: _screens,
      ),
      bottomNavigationBar: WaterDropNavBar(
        backgroundColor: Colors.white,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(_selectedIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad);
        },
        selectedIndex: _selectedIndex,
        inactiveIconColor: Colors.red,
        waterDropColor: Colors.red,
        bottomPadding: 15,
        barItems: [
          BarItem(
            filledIcon: Icons.bookmark_rounded,
            outlinedIcon: Icons.bookmark_border_rounded,
          ),
          BarItem(
              filledIcon: Icons.favorite_rounded,
              outlinedIcon: Icons.favorite_border_rounded),
          BarItem(
              filledIcon: Icons.search_rounded,
              outlinedIcon: Icons.search_outlined),
          BarItem(
              filledIcon: Icons.person_rounded,
              outlinedIcon: Icons.person_outline),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}



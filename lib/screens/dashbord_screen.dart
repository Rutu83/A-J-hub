import 'package:allinone_app/screens/business_screen.dart';
import 'package:allinone_app/screens/home_screen.dart';
import 'package:allinone_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
         HomeScreen(),
          BusinessScreen(),
          Center(
            child: Text(
              'Rewards Page',
              style: TextStyle(fontSize: 24),
            ),
          ),
          ProfileScreen()
        ],
      ),
      bottomSheet: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildMenuItem(Icons.home, "Home", 0),
                      _buildMenuItem(Icons.business, "My Business", 1),
                      Container(
                        height: 80,
                        width: 80,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      _buildMenuItem(Icons.card_giftcard, "Reward", 2),
                      _buildMenuItem(Icons.account_circle, "Account", 3),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Menu Item Widget
  Widget _buildMenuItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _pageController.jumpToPage(index);
      },
      child: Column(
        children: [
          Icon(icon,
              size: 30,
              color: _selectedIndex == index ? Colors.red : Colors.grey),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.red : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
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

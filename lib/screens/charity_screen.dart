import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CharityScreen extends StatefulWidget {
  const CharityScreen({super.key});

  @override
  State<CharityScreen> createState() => _CharityScreenState();
}

class _CharityScreenState extends State<CharityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        titleSpacing: 7.w,
        title: Text(
          'Charity',
          style: GoogleFonts.roboto(
            fontSize: 16.0.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          buildImage(),
          const SizedBox(height: 10),
          buildTabBar(),
          Expanded(child: buildTabBarView()),
        ],
      ),
    );
  }

  Widget buildImage() {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Widget buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: List.generate(5, (index) {
        return CustomTab(
          text: 'Tab ${index + 1}',
          isSelected: _tabController.index == index,
        );
      }),dividerColor: Colors.transparent,
      indicatorColor: Colors.transparent, // Hide the default indicator
      isScrollable: false,
      labelPadding: const EdgeInsets.fromLTRB(3, 5, 3, 3),
    );
  }

  Widget buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: const [
        Center(child: Text('Content for Tab 1')),
        Center(child: Text('Content for Tab 2')),
        Center(child: Text('Content for Tab 3')),
        Center(child: Text('Content for Tab 4')),
        Center(child: Text('Content for Tab 5')),
      ],
    );
  }
}

class CustomTab extends StatelessWidget {
  final String text;
  final bool isSelected;

  const CustomTab({
    super.key,
    required this.text,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: isSelected ? Colors.red : Colors.grey),
        color: isSelected ? Colors.red : Colors.grey,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black, // Change text color based on selection
          ),
        ),
      ),
    );
  }
}

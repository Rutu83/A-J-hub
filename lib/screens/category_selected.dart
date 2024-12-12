import 'dart:async';
import 'dart:convert';
import 'package:allinone_app/dynamic_fram/fram_1.dart';
import 'package:allinone_app/dynamic_fram/fram_2.dart';
import 'package:allinone_app/dynamic_fram/fram_3.dart';
import 'package:allinone_app/screens/business_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategorySelected extends StatefulWidget {
  final List<String> imagePaths;

  const CategorySelected({super.key, required this.imagePaths});

  @override
  CategorySelectedState createState() => CategorySelectedState();
}

class CategorySelectedState extends State<CategorySelected> {
  Timer? _autoScrollTimer;
  int selectedIndex = 0; // Index for selected image
  int selectedFrameIndex = 0; // Index for selected frame
  String businessName = ' ';
  String ownerName = ' ';
  String mobileNumber = ' ';
  String address = ' ';
  final List<Widget> frameWidgets = [];


  @override
  void initState() {
    super.initState();

    printActiveBusinessData();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  Future<void> printActiveBusinessData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? activeBusinessData = prefs.getString('active_business');

    if (activeBusinessData != null) {
      final activeBusiness = json.decode(activeBusinessData);

      // Set data to variables
      setState(() {
        businessName = activeBusiness['business_name'] ?? 'Not Provided';
        ownerName = activeBusiness['owner_name'] ?? 'Not Provided';
        mobileNumber = activeBusiness['mobile_number'] ?? 'Not Provided';
        address = activeBusiness['address'] ?? 'Not Provided';
      });

      frameWidgets.addAll([
        Fram1(
          businessName: businessName.toString(),
          phoneNumber: mobileNumber,
          emailAddress: 'business2@example.com',
          address: '456 Another St, City',
        ),
        Fram2(
          businessName: businessName.toString(),
          phoneNumber: mobileNumber,
          emailAddress: 'business2@example.com',
          address: '456 Another St, City',
        ),
        Fram3(
          businessName: businessName.toString(),
          phoneNumber: mobileNumber,
          emailAddress: 'business2@example.com',
          address: '456 Another St, City',
        ),
      ]);

    } else {
      _showNoBusinessDialog();
    }
  }

  void _showNoBusinessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No Active Business'),
          content: const Text(
            'No active business data found. Please add or select a business.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog and navigate back
                Navigator.pop(context); // Go back to the previous screen
              },
              child: const Text(
                'Back',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const BusinessList()),
                );
              },
              child: const Text(
                'Go to Business List',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Select Frame',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Poster image with dynamic frame
          SizedBox(
            height: 0.504.sh,
            width: 1.sw,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main Image
                Positioned(
                  left: 5.w,
                  right: 5.w,
                  top: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: _buildImage(widget.imagePaths[selectedIndex]),
                  ),
                ),

                Positioned(
                  left: 7.0,
                  right: 5.0,
                  top: 0,
                  bottom: 0,
                  child: PageView.builder(
                    itemCount: frameWidgets.length,
                    controller: PageController(initialPage: selectedFrameIndex),
                    onPageChanged: (index) {
                      setState(() {
                        selectedFrameIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return frameWidgets[index];
                    },
                  ),
                ),

                // Indicator at the bottom

                // Frame overlay
                // Positioned(
                //   left: 7.w,
                //   right: 5.w,
                //   top: 0,
                //   bottom: 0,
                //   child: Fram1(
                //     businessName: businessName.toString(),
                //     phoneNumber: mobileNumber.toString(),
                //     emailAddress: 'business2@example.com',
                //     address: address.toString(),),
                // ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          Positioned(
            bottom: 1,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                frameWidgets.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedFrameIndex == index
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 8.h),
          // Image Grid for selecting different images
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8.r),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: widget.imagePaths.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4.0,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22.r),
                          child: _buildImage(widget.imagePaths[index]),
                        ),
                      ),
                      if (selectedIndex == index)
                        Positioned(
                          bottom: 5.h,
                          right: 5.w,
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: Colors.red,
                            size: 28.sp,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, color: Colors.red);
        },
      );
    }
  }
}


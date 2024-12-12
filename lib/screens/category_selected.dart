import 'dart:async';
import 'dart:convert';
import 'package:allinone_app/screens/business_list.dart';
import 'package:http/http.dart' as http;
import 'package:allinone_app/main.dart';
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

  final List<String> framePaths = [
    'assets/images/fram7.png',
    'assets/images/fram8.png',
    'assets/images/fram9.png',
    'assets/images/fram10.png'
  ];

  @override
  void initState() {
    super.initState();
    printActiveBusinessData();
    startAutoScroll();
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

  void startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        selectedFrameIndex = (selectedFrameIndex + 1) % framePaths.length;
      });
    });
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
            height: 0.44.sh,
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
                    borderRadius: BorderRadius.circular(8.r),
                    child: _buildImage(widget.imagePaths[selectedIndex]),
                  ),
                ),

                // Frame overlay
                Positioned(
                  left: 5.w,
                  right: 5.w,
                  top: 0,
                  bottom: 0,
                  child: FrameOverlayWidget(
                    framePath: framePaths[selectedFrameIndex],
                    businessName: businessName.isNotEmpty ? businessName : 'Business Name',
                    phoneNumber: mobileNumber.isNotEmpty ? mobileNumber : 'Phone Number',
                    email: ownerName.isNotEmpty ? ownerName : 'Owner Name',
                    address: address.isNotEmpty ? address : 'Address',
                  ),
                ),
              ],
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

class FrameOverlayWidget extends StatelessWidget {
  final String framePath;
  final String businessName;
  final String phoneNumber;
  final String email;
  final String address;

  const FrameOverlayWidget({
    Key? key,
    required this.framePath,
    required this.businessName,
    required this.phoneNumber,
    required this.email,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background frame image
        Image.asset(
          framePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),

        // Business name
        Positioned(
          top: 20,
          left: 20,
          child: Text(
            businessName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Phone number
        Positioned(
          top: 50,
          left: 20,
          child: Row(
            children: [
              const Icon(Icons.phone, color: Colors.white, size: 14),
              const SizedBox(width: 5),
              Text(
                phoneNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Email
        Positioned(
          top: 80,
          left: 20,
          child: Row(
            children: [
              const Icon(Icons.email, color: Colors.white, size: 14),
              const SizedBox(width: 5),
              Text(
                email,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Address
        Positioned(
          top: 110,
          left: 20,
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 14),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Additional Data 1: Footer Text
        Positioned(
          bottom: 20,
          left: 20,
          child: Text(
            "Powered by YourAppName",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        // Additional Data 2: Center Overlay Text
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: MediaQuery.of(context).size.width * 0.3,
          child: Text(
            "Your Frame Center Info",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1.5, 1.5),
                  blurRadius: 3.0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:allinone_app/screens/business_form.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategorySelected extends StatefulWidget {
  final List<String> imagePaths;

  const CategorySelected({super.key, required this.imagePaths});

  @override
  CategorySelectedState createState() => CategorySelectedState();
}

class CategorySelectedState extends State<CategorySelected> {
  int selectedIndex = 0;  // Fixed image index
  int selectedFrameIndex = 0;  // Index for sliding frames

  // Define the available frames
  final List<String> framePaths = [
    'assets/images/fram1.png',  // Add frame1
    'assets/images/fram2.png',
    '/mnt/data/Yw7AIu5jct7REjp5Q2V5q2z2.png',  // Other frame image path
  ];

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive design
    ScreenUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Select Frame',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,  // Responsive font size
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),  // Responsive icon size
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/editing.png',
              width: 30.w,  // Responsive width
              height: 30.h,  // Responsive height
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BusinessForm(), // Open BusinessForm
                ),
              );
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/icons/download.png',
              width: 35.w,  // Responsive width
              height: 35.h,  // Responsive height
              color: Colors.black,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),  // Responsive radius
                ),
                backgroundColor: Colors.white,
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),  // Responsive padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Center(
                          child: Container(
                            height: 6.h,  // Responsive height
                            width: 40.w,  // Responsive width
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(22.r),  // Responsive radius
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),  // Responsive spacing
                        Row(
                          children: [
                            Container(
                              height: 30.h,  // Responsive height
                              width: 4.w,  // Responsive width
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12.r),  // Responsive radius
                              ),
                            ),
                            SizedBox(width: 12.w),  // Responsive spacing
                            Text(
                              'Aj Hug Pro',
                              style: TextStyle(
                                fontSize: 24.sp,  // Responsive font size
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),  // Responsive spacing
                        Center(
                          child: Text(
                            'Watch a Video or Subscribe to save this \nTemplate',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.sp,  // Responsive font size
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),  // Responsive spacing
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Handle "Watch Video" action
                              },
                              child: Container(
                                height: 100.h,  // Responsive height
                                width: double.infinity,  // Full width
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(15.r),  // Responsive radius
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6.0,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(16.r),  // Responsive padding
                                child: Row(
                                  children: [
                                    Icon(Icons.play_circle_fill, size: 50.sp, color: Colors.red),  // Responsive icon size
                                    SizedBox(width: 16.w),  // Responsive spacing
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Watch Video',
                                          style: TextStyle(fontSize: 16.sp),  // Responsive font size
                                        ),
                                        SizedBox(height: 4.h),  // Responsive spacing
                                        Text(
                                          'To Save This Template',
                                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),  // Responsive font size
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),  // Responsive spacing
                            GestureDetector(
                              onTap: () {
                                // Handle "Save Template" action
                              },
                              child: Container(
                                height: 100.h,  // Responsive height
                                width: double.infinity,  // Full width
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(15.r),  // Responsive radius
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6.0,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(16.r),  // Responsive padding
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/crown.png',
                                      width: 50.w,  // Responsive width for crown icon
                                      height: 50.h,  // Responsive height for crown icon
                                    ),
                                    SizedBox(width: 16.w),  // Responsive spacing
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Subscription',
                                          style: TextStyle(fontSize: 16.sp),  // Responsive font size
                                        ),
                                        SizedBox(height: 4.h),  // Responsive spacing
                                        Text(
                                          'Unlock All Pro Template & Remove Ads',
                                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),  // Responsive font size
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),  // Responsive spacing
                      ],
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(width: 10.w),  // Responsive spacing
        ],
      ),
      body: Column(
        children: [
          // Fixed Image with frame sliding applied
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.506,  // Responsive height for the main container
            width: MediaQuery.of(context).size.width,  // Full width to cover the screen
            child: Stack(
              alignment: Alignment.center,
              children: [

                // Main image container with Positioned
                Positioned(
                  left: 5.w,  // Responsive left positioning
                  right: 5.w,  // Responsive right positioning
                  top: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),  // Responsive border radius for the main image
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.53,  // Responsive height of the image
                      width: MediaQuery.of(context).size.width - 10.w,  // Responsive width with positioning adjustment
                      child: _buildImage(widget.imagePaths[selectedIndex]),  // Main image
                    ),
                  ),
                ),
                // Frame overlay (selected frame)
                Positioned(
                  left: 5.w,  // Match left position with main image
                  right: 5.w,  // Match right position with main image
                  top: 0,
                  bottom: 0,
                  child: CarouselSlider.builder(
                    itemCount: framePaths.length,
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.54,  // Match the height of the main image
                      enableInfiniteScroll: false,
                      enlargeCenterPage: false,
                      viewportFraction: 1.0,  // Show only one frame at a time
                      onPageChanged: (index, reason) {
                        setState(() {
                          selectedFrameIndex = index;
                        });
                      },
                    ),
                    itemBuilder: (context, index, realIndex) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.asset(
                          framePaths[index],
                          fit: BoxFit.fitWidth,
                          width: MediaQuery.of(context).size.width - 10.w,  // Ensure frame width matches the main image
                          height: MediaQuery.of(context).size.height * 0.54,  // Ensure frame height matches the main image
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Dots Indicator for the frame slider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: framePaths.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => setState(() {
                  selectedFrameIndex = entry.key;
                }),
                child: Container(
                  width: 12.w,  // Responsive size for dots
                  height: 12.h,  // Responsive size for dots
                  margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),  // Responsive margins
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedFrameIndex == entry.key ? Colors.red : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8.h),  // Responsive spacing

          // Image Grid for selecting different images (if needed)
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8.r),  // Responsive padding
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.w,  // Responsive spacing
                mainAxisSpacing: 12.h,  // Responsive spacing
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
                          borderRadius: BorderRadius.circular(15.r),  // Responsive border radius
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4.0,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22.r),  // Responsive border radius
                          child: _buildImage(widget.imagePaths[index]),
                        ),
                      ),
                      if (selectedIndex == index)
                        Positioned(
                          bottom: 5.h,  // Responsive position for check icon
                          right: 5.w,
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: Colors.red,
                            size: 28.sp,  // Responsive icon size
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8.h),  // Responsive spacing
        ],
      ),
    );
  }

  // Function to build image based on URL or asset path
  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error)); // Fallback for errors
        },
      );
    } else {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error)); // Fallback for errors
        },
      );
    }
  }
}

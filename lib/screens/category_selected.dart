// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:io';

import 'package:allinone_app/screens/category_edit_business_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart'; // For downloading images
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart'; // For file storage paths
import 'package:permission_handler/permission_handler.dart'; // For permissions
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path; // For manipulating file paths
import 'package:flutter/services.dart';


class CategorySelected extends StatefulWidget {
  final List<String> imagePaths;

  const CategorySelected({super.key, required this.imagePaths});

  @override
  CategorySelectedState createState() => CategorySelectedState();
}

class CategorySelectedState extends State<CategorySelected> {
  int selectedIndex = 0; // Index for selected image
  int selectedFrameIndex = 0; // Index for sliding frames
  bool isDownloading = false; // Flag to manage download state

  // Define the available frames
  final List<String> framePaths = [
    'assets/images/fram1.png', // Add frame1
    'assets/images/fram2.png',
    '/mnt/data/Yw7AIu5jct7REjp5Q2V5q2z2.png', // Other frame image path
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
            fontSize: 18.sp, // Responsive font size
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp), // Responsive icon size
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/editing.png',
              width: 25.w, // Responsive width
              height: 25.h, // Responsive height
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryEditBusinessForm(), // Open BusinessForm
                ),
              );
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/icons/download.png',
              width: 30.w, // Responsive width
              height: 30.h, // Responsive height
              color: Colors.black,
            ),
            onPressed: () {
              _downloadImage(widget.imagePaths[selectedIndex]);
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/icons/share.png',
              width: 22.w, // Responsive width
              height: 22.h, // Responsive height
              color: Colors.black,
            ),
            onPressed: () {
              _shareImage(widget.imagePaths[selectedIndex]);
            },
          ),

          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: Column(
        children: [
          // Fixed Image with frame sliding applied
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45, // Responsive height for the main container
            width: MediaQuery.of(context).size.width, // Full width to cover the screen
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main image container with Positioned
                Positioned(
                  left: 5.w, // Responsive left positioning
                  right: 5.w, // Responsive right positioning
                  top: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r), // Responsive border radius for the main image
                    child: _buildImage(widget.imagePaths[selectedIndex]), // Main image
                  ),
                ),
                // Frame overlay (selected frame)
                Positioned(
                  left: 5.w, // Match left position with main image
                  right: 5.w, // Match right position with main image
                  top: 0,
                  bottom: 0,
                  child: CarouselSlider.builder(
                    itemCount: framePaths.length,
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.54, // Match the height of the main image
                      enableInfiniteScroll: false,
                      enlargeCenterPage: false,
                      viewportFraction: 1.0, // Show only one frame at a time
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
                          width: MediaQuery.of(context).size.width - 10.w, // Ensure frame width matches the main image
                          height: MediaQuery.of(context).size.height * 0.54, // Ensure frame height matches the main image
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
                  width: 12.w, // Responsive size for dots
                  height: 12.h, // Responsive size for dots
                  margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w), // Responsive margins
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedFrameIndex == entry.key ? Colors.red : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8.h), // Responsive spacing

          // Image Grid for selecting different images
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8.r), // Responsive padding
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.w, // Responsive spacing
                mainAxisSpacing: 12.h, // Responsive spacing
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
                          borderRadius: BorderRadius.circular(15.r), // Responsive border radius
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4.0,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22.r), // Responsive border radius
                          child: _buildImage(widget.imagePaths[index]),
                        ),
                      ),
                      if (selectedIndex == index)
                        Positioned(
                          bottom: 5.h, // Responsive position for check icon
                          right: 5.w,
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: Colors.red,
                            size: 28.sp, // Responsive icon size
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8.h), // Responsive spacing
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

  // Request storage permissions before downloading
  Future<void> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (status.isDenied) {
        await Permission.storage.request();
      }
      // For Android 11 and above
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
    }
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      await _checkStoragePermission(); // Ensure storage permission is granted
      setState(() {
        isDownloading = true;
      });

      Dio dio = Dio();
      var dir = Directory('/storage/emulated/0/Pictures'); // Save directly to Pictures folder
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      String fileName = path.basename(imageUrl); // Extract file name from URL
      String savePath = path.join(dir.path, fileName); // Define save path

      // Download the image and save to the defined path
      await dio.download(imageUrl, savePath);

      setState(() {
        isDownloading = false;
      });

      // Refresh the gallery after download
      await _refreshGallery(savePath);
      _openImage(savePath);

      if (kDebugMode) {
        print(savePath);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Image downloaded to $savePath'),
      ));
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to download image: $e'),
      ));
    }
  }



// Function to open the image file using an external app
  void _openImage(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      OpenFilex.open(filePath); // Opens the file with the associated app
    } else {
      print("File does not exist at $filePath");
    }
  }


  // Function to refresh the gallery after saving an image
  Future<void> _refreshGallery(String filePath) async {
    final result = await File(filePath).create(recursive: true);
    await result.setLastModified(DateTime.now());

    // Add a short delay
    await Future.delayed(const Duration(seconds: 1));

    const channel = MethodChannel('com.allinonemarketing.allinone_app/gallery');
    await channel.invokeMethod('refreshGallery', {'filePath': filePath});
  }


  // Function to share image
  Future<void> _shareImage(String imagePath) async {
    try {
      // If it's a remote URL, download the image first
      if (imagePath.startsWith('http')) {
        var dir = await getTemporaryDirectory();
        String fileName = imagePath.split('/').last;
        String savePath = "${dir.path}/$fileName";
        await Dio().download(imagePath, savePath);
        imagePath = savePath; // Update the path to the local downloaded image
      }

      // Share the image using XFile
      XFile xFile = XFile(imagePath);
      Share.shareXFiles([xFile], text: 'Check out this image!');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to share image: $e'),
      ));
    }
  }
}


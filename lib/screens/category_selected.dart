// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously
import 'dart:io';
import 'dart:ui' as ui;
import 'package:allinone_app/screens/category_edit_business_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    'assets/images/fram1.png',
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
              width: 20.w, // Responsive width
              height: 20.h, // Responsive height
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryEditBusinessForm(),
                ),
              );
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/icons/download.png',
              width: 25.w, // Responsive width
              height: 25.h, // Responsive height
              color: Colors.black,
            ),
            onPressed: () {
              _downloadImage(widget.imagePaths[selectedIndex]);
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/icons/share.png',
              width: 18.w, // Responsive width
              height: 18.h, // Responsive height
              color: Colors.black,
            ),
            onPressed: () {
              _shareImage(widget.imagePaths[selectedIndex]);
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // Fixed Image with frame sliding applied
        SizedBox(
        height: 0.45.sh, // ScreenUtil for height
        width: 1.sw, // Full width of the screen
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main image container with Positioned
            Positioned(
              left: 5.w, // Responsive width
              right: 5.w,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r), // Responsive radius
                child: _buildImage(widget.imagePaths[selectedIndex]),
              ),
            ),
            // Frame overlay (selected frame)
            Positioned(
              left: 5.w,
              right: 5.w,
              top: 0,
              bottom: 0,
              child: CarouselSlider.builder(
                itemCount: framePaths.length,
                options: CarouselOptions(
                  height: 0.54.sh, // Responsive height
                  enableInfiniteScroll: false,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
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
                      width: 1.sw - 10.w, // Adjusted for screen width
                      height: 0.54.sh, // Adjusted for screen height
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
                  width: 12.w,
                  height: 12.h,
                  margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedFrameIndex == entry.key ? Colors.red : Colors.grey,
                  ),
                ),
              );
            }).toList(),
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
          SizedBox(height: 8.h),
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
          return const Center(child: Icon(Icons.error));
        },
      );
    } else {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error));
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
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
    }
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      await _checkStoragePermission();
      setState(() {
        isDownloading = true;
      });

      // Combine the image with the selected frame
      final combinedImage = await _combineImageAndFrame(imageUrl, framePaths[selectedFrameIndex]);

      // Convert the combined image to a PNG byte array
      final byteData = await combinedImage.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save the PNG bytes to a file
      var dir = Directory('/storage/emulated/0/Pictures/AJHUB');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      String fileName = path.basename(imageUrl);
      String savePath = path.join(dir.path, fileName);
      final file = File(savePath);
      await file.writeAsBytes(pngBytes);

      setState(() {
        isDownloading = false;
      });

      await _refreshGallery(savePath);
      _openImage(savePath);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Image downloaded to $savePath'),
      ));
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to download image: $e'),
      ));
    }
  }

  Future<ui.Image> _combineImageAndFrame(String imagePath, String framePath) async {
    final image = await _loadImage(imagePath);
    final frame = await _loadImage(framePath);

    // Create a recorder and canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Define sizes based on the maximum dimensions
    final size = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    // Draw the image
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    // Draw the frame on top
    canvas.drawImageRect(
      frame,
      Rect.fromLTWH(0, 0, frame.width.toDouble(), frame.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    // Create the combined image
    final combinedImage = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    return combinedImage;
  }


  Future<ui.Image> _loadImage(String path) async {
    final data = await (path.startsWith('http')
        ? NetworkAssetBundle(Uri.parse(path)).load(path)
        : rootBundle.load(path));
    return await decodeImageFromList(data.buffer.asUint8List());
  }

  // Function to open the image file using an external app
  void _openImage(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      OpenFilex.open(filePath);
    } else {
      if (kDebugMode) {
        print("File does not exist at $filePath");
      }
    }
  }

  // Function to refresh the gallery after saving an image
  Future<void> _refreshGallery(String filePath) async {
    final result = await File(filePath).create(recursive: true);
    await result.setLastModified(DateTime.now());
    await Future.delayed(const Duration(seconds: 1));

    const channel = MethodChannel('com.allinonemarketing.allinone_app/gallery');
    await channel.invokeMethod('refreshGallery', {'filePath': filePath});
  }

// Function to share image with selected frame overlay
  Future<void> _shareImage(String imagePath) async {
    try {
      // Combine the image with the selected frame
      final combinedImage = await _combineImageAndFrame(imagePath, framePaths[selectedFrameIndex]);

      // Convert the combined image to a PNG byte array
      final byteData = await combinedImage.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save the combined image to a temporary file for sharing
      var tempDir = await getTemporaryDirectory();
      String fileName = path.basename(imagePath).replaceAll('.', '_with_frame.');
      String savePath = path.join(tempDir.path, fileName);
      final file = File(savePath);
      await file.writeAsBytes(pngBytes);

      // Share the combined image with the label
      XFile xFile = XFile(savePath);
      Share.shareXFiles([xFile], text: 'Bust Lime Download');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to share image: $e'),
      ));
    }
  }

}


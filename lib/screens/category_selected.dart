import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:allinone_app/dynamic_fram/fram_1.dart';
import 'package:allinone_app/dynamic_fram/fram_2.dart';
import 'package:allinone_app/dynamic_fram/fram_3.dart';
import 'package:allinone_app/screens/business_list.dart';
import 'package:allinone_app/screens/category_edit_business_form.dart';
import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;



class CategorySelected extends StatefulWidget {
  final List<String> imagePaths;

  const CategorySelected({super.key, required this.imagePaths});

  @override
  CategorySelectedState createState() => CategorySelectedState();
}

class CategorySelectedState extends State<CategorySelected> {
  Timer? _autoScrollTimer;
  int selectedIndex = 0;
  int selectedFrameIndex = 0;
  String businessName = ' ';
  String emailAddress = ' ';
  String ownerName = ' ';
  String mobileNumber = ' ';
  String address = ' ';
  String website = ' ';
  List<Widget> frameWidgets = []; // Remove 'final' to make it mutable
  bool isLoading = true;
  bool allFramesLoaded = false;
  bool isFramesLoading = true;


  @override
  void initState() {
    super.initState();

    printActiveBusinessData();
    _loadFrames();
    _initializeData();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }


  Future<void> _initializeData() async {
    await _loadFrames();
    setState(() {
      isLoading = false; // Everything loaded
    });
  }


  Future<void> printActiveBusinessData() async {
    setState(() {
      isLoading = true; // Start the loading state
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? activeBusinessData = prefs.getString('active_business');

      if (activeBusinessData != null) {
        final activeBusiness = json.decode(activeBusinessData);

        if (kDebugMode) {
          print(activeBusiness);
        }

        // Set data to variables
        setState(() {
          businessName = activeBusiness['business_name'] ?? 'Not Provided';
          ownerName = activeBusiness['owner_name'] ?? 'Not Provided';
          mobileNumber = activeBusiness['mobile_number'] ?? 'Not Provided';
          emailAddress = activeBusiness['email'] ?? 'Not Provided';
          address = activeBusiness['address'] ?? 'Not Provided';
          website = activeBusiness['website'] ?? 'Not Provided';
        });

        // After fetching the data, load frames
        await _loadFrames();
      } else {
        _showNoBusinessDialog();
      }
    } catch (error) {
      print("Error loading active business data: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // End the loading state
      });
    }
  }

  Future<void> _loadFrames() async {
    setState(() {
      isFramesLoading = true; // Indicate frames are loading
    });

    try {
      // Simulate frame loading (replace this with actual loading logic if needed)
      await Future.delayed(const Duration(seconds: 2)); // Simulate loading delay

      // Create the frames with the fetched data
      frameWidgets = [
        Fram1(
          businessName: businessName,
          phoneNumber: mobileNumber,
          emailAddress: emailAddress,
          address: address,
        ),
        Fram2(
          businessName: businessName,
          phoneNumber: mobileNumber,
          emailAddress: emailAddress,
          address: address,
        ),
        Fram3(
          businessName: businessName,
          phoneNumber: mobileNumber,
          emailAddress: emailAddress,
          address: address,
          website: website,
        ),
      ];
    } catch (error) {
      print("Error loading frames: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading frames: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isFramesLoading = false; // Indicate frames are no longer loading
        allFramesLoaded = true; // Mark frames as fully loaded
      });
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
        ),  actions: [
        IconButton(
          icon: Image.asset(
            'assets/icons/editing.png',
            width: 20.w,
            height: 20.h,
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
          icon: const Icon(Icons.download, color: Colors.black),
          onPressed: () {
           // _downloadImage(widget.imagePaths[selectedIndex]);
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black),
          onPressed: () {
          //  _shareImage(widget.imagePaths[selectedIndex]);
          },
        ),

        const SizedBox(width: 10),
      ],

      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(), // Show progress indicator
      )
          : Column(
        children: [
          // Poster image with dynamic frame
          isFramesLoading
              ? _buildSkeletonLoader() // Show skeleton loader while loading
              :  SizedBox(
            height: 0.455.sh,
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
                  left: 6.0,
                  right: 0.0,
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
              ],
            ),
          ),
          SizedBox(height: 5.h),
          Row(
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
          )
        ],
      ),

    );
  }




  Widget _buildSkeletonLoader() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skeleton for main image
            Container(
              width: 1.sw,
              height: 0.455.sh,
              decoration: BoxDecoration(
                color: Colors.grey[300]!,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 16.h),
            // Skeleton for frame indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300]!,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Image with Placeholder
  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade300,
        ),
        errorWidget: (context, url, error) =>
        const Icon(Icons.error, color: Colors.red),
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

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing the dialog
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.red),
                const SizedBox(width: 16),
                Text(
                  message,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _refreshGallery(Uri fileUri) async {
    try {
      const methodChannel = MethodChannel('com.allinonemarketing.allinone_app/gallery');
      await methodChannel.invokeMethod('refreshGallery', {'fileUri': fileUri.toString()});
    } catch (e) {
      print('Error refreshing gallery: $e');
    }
  }


  Future<ui.Image> _combineImageAndFrame(String imagePath, String framePath) async {
    final ui.Image image = await _loadUiImage(imagePath);
    final ui.Image frame = await _loadUiImage(framePath);
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final paint = Paint();
    // Draw the main image
    canvas.drawImage(image, Offset.zero, paint);
    // Draw the frame overlay
    canvas.drawImage(frame, Offset.zero, paint);
    final combinedImage = recorder.endRecording().toImage(
      image.width,
      image.height,
    );
    return combinedImage;
  }


  Future<ui.Image> _loadUiImage(String imagePath) async {
    Uint8List bytes;

    if (imagePath.startsWith('http')) {
      // Fetch the image from the network
      final response = await http.get(Uri.parse(imagePath));
      if (response.statusCode == 200) {
        bytes = response.bodyBytes;
      } else {
        throw Exception('Failed to load network image: ${response.statusCode}');
      }
    } else {
      // Load local asset
      final ByteData data = await rootBundle.load(imagePath);
      bytes = Uint8List.view(data.buffer);
    }

    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }


  Future<void> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.manageExternalStorage.status;

      if (status.isDenied || status.isRestricted) {
        status = await Permission.manageExternalStorage.request();
      }

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required to save the image.')),
        );
        throw Exception('Storage permission denied');
      }
    } else {
      throw Exception('This functionality is only available on Android devices.');
    }
  }


//
//
//
// Widget _buildImage(String imagePath) {
//     if (imagePath.startsWith('http')) {
//       return CachedNetworkImage(
//         imageUrl: imagePath,
//         fit: BoxFit.cover,
//         placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
//         errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
//       );
//     } else {
//       return Image.asset(
//         imagePath,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) {
//           return const Icon(Icons.error, color: Colors.red);
//         },
//       );
//     }
//   }
}


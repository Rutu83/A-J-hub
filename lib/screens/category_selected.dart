// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:allinone_app/main.dart';
import 'package:allinone_app/screens/category_edit_business_form.dart';
import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
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
  int selectedIndex = 0; // Index for selected image
  int selectedFrameIndex = 0; // Index for sliding frames
  bool isDownloading = false; // Flag to manage download state
  double downloadProgress = 0.0;
  List<String> framePaths = []; // List to hold frame image paths
  String businessName = '';
  String ownerName = '';
  String mobileNumber = '';
  String address = '';





  Future<void> fetchBusinessData() async {
    const String apiUrl = 'https://ajhub.co.in/api/getbusinessprofile'; // No specific ID
    String? token = appStore.token; // Fetch token

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<dynamic> businesses = responseData['data'];

        if (kDebugMode) {
          print(response.body);
        }

        if (businesses.isNotEmpty) {
          // Filter active businesses based on the status field
          List<dynamic> activeBusinesses = businesses.where((business) {
            return business['status'] == 'active'; // or `business['is_active'] == true`
          }).toList();

          if (activeBusinesses.isNotEmpty) {
            final activeBusiness = activeBusinesses.first;

            // Update the TextEditingControllers with the active business data

            businessName = activeBusiness['business_name'] ?? '';
            ownerName = activeBusiness['owner_name'] ?? '';
            mobileNumber = activeBusiness['mobile_number'] ?? '';
           address = activeBusiness['address'] ?? '';

            if (kDebugMode) {
              print('Active business data loaded successfully.');
            }
          } else {
            if (kDebugMode) {
              print('No active businesses found');
            }
          }
        } else {
          if (kDebugMode) {
            print('No businesses found');
          }
        }
      } else {
        if (kDebugMode) {
          print('Failed to fetch business data: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching business data: $e');
      }
    }
  }



  // Function to load frames from JSON
  Future<void> _loadFrames() async {
    final String jsonString = await rootBundle.loadString('assets/frame_config.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);
    setState(() {
      framePaths = data['frames'].values.map<String>((frame) => frame['image'] as String).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFrames(); // Load frames when the widget is initialized
    fetchBusinessData();
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
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
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
              _downloadImage(widget.imagePaths[selectedIndex]);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
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
            height: 0.44.sh,
            width: 1.sw,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main image container with Positioned
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
                // Frame overlay (selected frame)
                Positioned(
                  left: 5.w,
                  right: 5.w,
                  top: 0,
                  bottom: 0,
                  child: CarouselSlider.builder(
                    itemCount: framePaths.length,
                    options: CarouselOptions(
                      height: 0.54.sh,
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
                        child: framePaths[index].startsWith('http')
                            ? CachedNetworkImage(
                          imageUrl: framePaths[index],
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 1.sw - 10.w,
                              height: 0.54.sh,
                              color: Colors.grey[300],
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 1.sw - 10.w,
                            height: 0.54.sh,
                            color: Colors.grey,
                            child: const Icon(Icons.error, color: Colors.red),
                          ),
                        )
                            : Image.asset(
                          framePaths[index],
                          fit: BoxFit.fitWidth,
                          width: 1.sw - 10.w,
                          height: 0.54.sh,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: const Icon(Icons.error, color: Colors.red),
                            );
                          },
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
                  width: 6.w,
                  height: 6.h,
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
        ],
      ),
    );
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      _showLoadingDialog(context, "Downloading...");
      await _checkStoragePermission();

      final combinedImage = await _combineImageAndFrame(
        imageUrl,
        framePaths[selectedFrameIndex],
      );
      final byteData = await combinedImage.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to public Pictures directory
      final dir = Directory('/storage/emulated/0/Pictures/AJHUB');
      if (!await dir.exists()) await dir.create(recursive: true);

      String fileName = 'AJHUB_${DateTime.now().millisecondsSinceEpoch}.png';
      String savePath = path.join(dir.path, fileName);

      final file = File(savePath);
      await file.writeAsBytes(pngBytes);

      // Notify MediaStore about the new file
      final Uri uri = Uri.file(savePath);
      await _refreshGallery(uri);

      Navigator.pop(context); // Dismiss the loading dialog

      // Show success message with file path
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image downloaded successfully! \nPath: $savePath'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4), // Extend duration to allow users to read the path
          behavior: SnackBarBehavior.floating, // Floating snackbar for better visibility
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Ensure dialog is dismissed in case of error
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to download image: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }



  Future<void> _shareImage(String imagePath) async {
    try {
      _showLoadingDialog(context, "Preparing to Share...");
      final combinedImage = await _combineImageAndFrame(imagePath, framePaths[selectedFrameIndex]);

      final byteData = await combinedImage.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      XFile xFile = XFile.fromData(pngBytes, mimeType: 'image/png');
      await Share.shareXFiles([xFile], text: 'Aj Hub Mobile App');

      Navigator.pop(context); // Dismiss the loading dialog
    } catch (e) {
      Navigator.pop(context); // Ensure dialog is dismissed in case of error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to share image: $e'),
      ));
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
}



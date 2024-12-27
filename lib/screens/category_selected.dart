import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:allinone_app/dynamic_fram/fram_1.dart';
import 'package:allinone_app/dynamic_fram/fram_2.dart';
import 'package:allinone_app/dynamic_fram/fram_3.dart';
import 'package:allinone_app/dynamic_fram/fram_4.dart';
import 'package:allinone_app/dynamic_fram/fram_5.dart';
import 'package:allinone_app/screens/active_user_screen2.dart';
import 'package:allinone_app/screens/business_list.dart';
import 'package:allinone_app/screens/category_edit_business_form.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'dart:ui' as ui;

class CategorySelected extends StatefulWidget {
  final List<String> imagePaths;
  final String title;

  const CategorySelected({super.key, required this.imagePaths, required this.title});

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
  List<Widget> frameWidgets = [];
  bool isLoading = true;
  bool allFramesLoaded = false;
  bool isFramesLoading = true;
  bool isProcessing = false;
  String progressMessage = ""; // Message to show during processing

  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
print(widget.title);
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
      isLoading = true; // Start loading
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? activeBusinessData = prefs.getString('active_business');

      if (activeBusinessData != null) {
        final activeBusiness = json.decode(activeBusinessData);

        if (kDebugMode) {
          print(activeBusiness);
        }

        setState(() {
          businessName = activeBusiness['business_name'] ?? 'Not Provided';
          ownerName = activeBusiness['owner_name'] ?? 'Not Provided';
          mobileNumber = activeBusiness['mobile_number'] ?? 'Not Provided';
          emailAddress = activeBusiness['email'] ?? 'Not Provided';
          address = activeBusiness['address'] ?? 'Not Provided';
          website = activeBusiness['website'] ?? 'Not Provided';
        });

        await _loadFrames();
      } else {
        _showNoBusinessDialog();
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error loading active business data: $error");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // End loading
      });
    }
  }

  Future<void> _loadFrames() async {
    setState(() {
      isFramesLoading = true;
    });

    try {
    frameWidgets = [
        Fram1(
          businessName: businessName,
          phoneNumber: mobileNumber,
          emailAddress: emailAddress,
          address: address,
          website: website,
        ),
        Fram2(
          businessName: businessName,
          phoneNumber: mobileNumber,
          emailAddress: emailAddress,
          address: address,
          website: website,
        ),
        Fram3(
          businessName: businessName,
          phoneNumber: mobileNumber,
          emailAddress: emailAddress,
          address: address,
          website: website,
        ),
        Fram4(
          businessName: businessName,
          phoneNumber: mobileNumber,
          emailAddress: emailAddress,
          address: address,
          website: website,
        ),
        Fram5(
          businessName: businessName,
          phoneNumber: mobileNumber,
          emailAddress: emailAddress,
          address: address,
          website: website,
        ),
      ];
    } catch (error) {
      if (kDebugMode) {
        print("Error loading frames: $error");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading frames: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isFramesLoading = false;
        allFramesLoaded = true;
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
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Back',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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



  static const maxDownloads = 5;

  Future<void> _incrementDownloadCount(String filePath) async {
    final prefs = await SharedPreferences.getInstance();

    // Safely decode the data and ensure type casting
    Map<String, dynamic> downloadedPaths = json.decode(
      prefs.getString('downloaded_paths') ?? '{}',
    );
    Map<String, List<String>> downloadedPathsSafe = downloadedPaths.map(
          (key, value) => MapEntry(key, List<String>.from(value ?? [])),
    );

    Map<String, int> categoryDownloadCount = Map<String, int>.from(
      json.decode(prefs.getString('category_download_count') ?? '{}'),
    );

    // Initialize counts for the current title if not already present
    categoryDownloadCount[widget.title] = categoryDownloadCount[widget.title] ?? 0;
    downloadedPathsSafe[widget.title] = downloadedPathsSafe[widget.title] ?? [];

    // Check if the download limit is reached
    if (categoryDownloadCount[widget.title]! < maxDownloads) {
      categoryDownloadCount[widget.title] = categoryDownloadCount[widget.title]! + 1;
      downloadedPathsSafe[widget.title]!.add(filePath);

      await prefs.setString('category_download_count', json.encode(categoryDownloadCount));
      await prefs.setString('downloaded_paths', json.encode(downloadedPathsSafe));

      if (categoryDownloadCount[widget.title] == maxDownloads) {
     //   _showCompletionPopup(widget.title);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum downloads for "${widget.title}" reached!')),
      );
    }
  }


  void _showCompletionPopup(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Completed'),
        content: Text('All 5 images for "$title" have been successfully downloaded.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<int> _getDownloadCount() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, int> categoryDownloadCount =
    Map<String, int>.from(json.decode(prefs.getString('category_download_count') ?? '{}'));
    _showDownloads();
    return categoryDownloadCount[widget.title] ?? 0;
  }

  Future<void> _showDownloads() async {
    final prefs = await SharedPreferences.getInstance();

    // Decode the data safely and ensure correct type casting
    Map<String, dynamic> downloadedPaths = json.decode(
      prefs.getString('downloaded_paths') ?? '{}',
    );
    Map<String, List<String>> downloadedPathsSafe = downloadedPaths.map(
          (key, value) => MapEntry(key, List<String>.from(value ?? [])),
    );

    // Safely access the paths for the current title
    List<String> pathsForTitle = downloadedPathsSafe[widget.title] ?? [];


  }



  Future<void> _downloadImage() async {
    setState(() {
      isProcessing = true;
      progressMessage = "Downloading image...";
    });

    try {
      final downloadCount = await _getDownloadCount();
      if (downloadCount >= maxDownloads) {
        _showUpgradePopup();
        return;
      }

      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Unable to capture frame.');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null) {
        final directory = Directory('/storage/emulated/0/Pictures/AJHUB');
        if (!directory.existsSync()) directory.createSync(recursive: true);

        final filePath =
            '${directory.path}/frame_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);

        await GallerySaver.saveImage(filePath, albumName: 'MyFrames');
        await _incrementDownloadCount(filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.grey.shade400,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Image downloaded successfully!',
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );


      }
    } catch (error) {
      if (kDebugMode) {
        print("Error downloading image: $error");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.grey.shade400,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Error downloading image: $error',
                  style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );


    } finally {
      setState(() {
        isProcessing = false;
        progressMessage = "";
      });
    }
  }


  void _showUpgradePopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade Membership'),
        content: const Text(
            'You have reached the maximum download limit. Upgrade to premium membership for unlimited downloads.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActivateMembershipPage()),
              );
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }


  Future<void> _shareImage() async {
    setState(() {
      isProcessing = true;
      progressMessage = "Preparing image for sharing...";
    });

    try {
      final boundary =
      _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Unable to capture frame.');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/shared_frame_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes!);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'AJ HUb Mobile App!',
      );
    } catch (error) {
      if (kDebugMode) {
        print("Error sharing image: $error");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing image: $error')),
      );
    } finally {
      setState(() {
        isProcessing = false;
        progressMessage = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final containerWidth = MediaQuery.of(context).size.width * 0.97;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow for a cleaner design
        title: Text(
          'Select Frame',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold, // Emphasize title
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Edit Button with Background
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add spacing
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200], // Light background color
                shape: BoxShape.circle,  // Circular background
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 24.0,
                  color: Colors.black,
                ),
                tooltip: 'Edit Category',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryEditBusinessForm(),
                    ),
                  );
                },
              ),
            ),
          ),

          // Download Button with Background
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.file_download,
                  size: 24.0,
                  color: Colors.black,
                ),
                tooltip: 'Download Image',
                onPressed: !isProcessing ? _downloadImage : null,
              ),
            ),
          ),

          // Share Button with Background
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.share,
                  size: 24.0,
                  color: Colors.black,
                ),
                tooltip: 'Share Image',
                onPressed: !isProcessing ? _shareImage : null,
              ),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                RepaintBoundary(
                  key: _repaintKey,
                  child: SizedBox(
                    height: containerWidth,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: widget.imagePaths[selectedIndex],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0.0,
                          right: 0.0,
                          top: 0,
                          bottom: 0,
                          child: PageView.builder(
                            itemCount: frameWidgets.length,
                            controller: PageController(initialPage: selectedFrameIndex),
                            scrollDirection: Axis.horizontal,
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
                ),
                SizedBox(height: 10.h),
                // Frame Indicators
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
                        color: selectedFrameIndex == index ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Bottom Image Selection
                GridView.builder(
                  padding: const EdgeInsets.all(10),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
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
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4.0,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: widget.imagePaths[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                          ),
                          if (selectedIndex == index)
                            const Positioned(
                              bottom: 5,
                              right: 5,
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text(progressMessage, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

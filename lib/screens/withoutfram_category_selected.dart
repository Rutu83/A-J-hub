import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:ajhub_app/dynamic_fram/fram_6.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/category_edit_business_form.dart';
import 'package:ajhub_app/screens/locked_feature_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ajhub_app/main.dart';

class WithoutFramCategorySelected extends StatefulWidget {
  final List<String> imagePaths;
  final String title;

  const WithoutFramCategorySelected(
      {super.key, required this.imagePaths, required this.title});

  @override
  WithoutFramCategorySelectedState createState() =>
      WithoutFramCategorySelectedState();
}

class WithoutFramCategorySelectedState
    extends State<WithoutFramCategorySelected> {
  Timer? _autoScrollTimer;
  int selectedIndex = 0;
  int selectedFrameIndex = 0;
  String businessName = ' ';
  String emailAddress = ' ';
  String ownerName = ' ';
  String status = ' ';
  String mobileNumber = ' ';
  String address = ' ';
  String website = ' ';
  List<Widget> frameWidgets = [];
  bool isLoading = true;
  bool allFramesLoaded = false;
  bool isFramesLoading = true;
  bool isProcessing = false;
  String progressMessage = "";
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
      isLoading = false;
    });
  }

  Future<void> printActiveBusinessData() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? activeBusinessData = prefs.getString('active_business');

      if (activeBusinessData != null) {
        final activeBusiness = json.decode(activeBusinessData);

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
        setState(() {
          businessName = 'Aj hub Mobile App';
          ownerName = 'Aj hub Mobile App';
          mobileNumber = '78630 45542';
          emailAddress = 'support@ajhub.co.in';
          address = 'Palanpur , Gujarat - 385001';
          website = 'https://ajhub.co.in';
        });
        //   _showNoBusinessDialog();

        await _loadFrames();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadFrames() async {
    setState(() {
      isFramesLoading = true;
    });

    try {
      frameWidgets = [
        Fram6(),
      ];
    } catch (error) {
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

  // void _showNoBusinessDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('No Active Business'),
  //         content: const Text(
  //           'No active business data found. Please add or select a business.',
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               Navigator.pop(context);
  //             },
  //             child: const Text(
  //               'Back',
  //               style: TextStyle(color: Colors.grey),
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => const BusinessList()),
  //               );
  //             },
  //             child: const Text(
  //               'Go to Business List',
  //               style: TextStyle(color: Colors.red),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Get today's date string (e.g., '2023-10-27') to track daily limits
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _incrementDownloadCount(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayDateString();
    final limit = appStore.planLimits.getLimit('download_poster_daily');

    // Store simple daily count
    Map<String, int> dailyDownloadCount = Map<String, int>.from(
        json.decode(prefs.getString('daily_download_count') ?? '{}'));

    // Clean up old dates
    dailyDownloadCount.removeWhere((key, value) => key != today);

    dailyDownloadCount[today] = (dailyDownloadCount[today] ?? 0) + 1;
    await prefs.setString(
        'daily_download_count', json.encode(dailyDownloadCount));

    // Store paths if needed (optional, keeping backward compatibility mostly)
    Map<String, dynamic> downloadedPaths =
        json.decode(prefs.getString('downloaded_paths') ?? '{}');
    Map<String, List<String>> downloadedPathsSafe = downloadedPaths
        .map((key, value) => MapEntry(key, List<String>.from(value ?? [])));

    downloadedPathsSafe[widget.title] = downloadedPathsSafe[widget.title] ?? [];
    downloadedPathsSafe[widget.title]!.add(filePath);
    await prefs.setString('downloaded_paths', json.encode(downloadedPathsSafe));

    if (dailyDownloadCount[today] == limit && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily download limit reached!')));
    }
  }

  Future<int> _getDownloadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayDateString();

    Map<String, int> dailyDownloadCount = Map<String, int>.from(
        json.decode(prefs.getString('daily_download_count') ?? '{}'));

    // Clean up old dates
    if (dailyDownloadCount.keys.any((key) => key != today)) {
      dailyDownloadCount.removeWhere((key, value) => key != today);
      await prefs.setString(
          'daily_download_count', json.encode(dailyDownloadCount));
    }

    return dailyDownloadCount[today] ?? 0;
  }

  Future<void> _downloadImage() async {
    setState(() {
      isProcessing = true;
      progressMessage = "Downloading image...";
    });

    try {
      final downloadCount = await _getDownloadCount();
      final limit = appStore.planLimits.getLimit('download_poster_daily');

      if (downloadCount >= limit) {
        _showUpgradePopup();
        return;
      }

      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
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

        final bool? success =
            await GallerySaver.saveImage(filePath, albumName: 'MyFrames');
        if (success == true) {
          await _incrementDownloadCount(filePath);
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
                    'Image downloaded successfully!',
                    style: GoogleFonts.poppins(
                        fontSize: 14.sp, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (error) {
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
                  style:
                      GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
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

  void _showUpgradePopup({bool isShare = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LockedFeatureScreen(
          featureName: isShare
              ? 'Daily Share Limit REACHED'
              : 'Daily Download Limit REACHED',
          description:
              'You have reached your daily limit for ${isShare ? "sharing" : "downloading"} business posters. Upgrade your plan to unlock more limits.',
          icon: isShare ? Icons.share : Icons.download,
        ),
      ),
    );
  }

  Future<void> fetchUserData() async {
    try {
      Map<String, dynamic> userDetail = await getUserDetail();

      status = userDetail['status'] ?? '';
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<int> _getShareCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayDateString();
    Map<String, int> dailyShareCount = Map<String, int>.from(
        json.decode(prefs.getString('daily_share_count') ?? '{}'));

    // Clean up old dates
    if (dailyShareCount.keys.any((key) => key != today)) {
      dailyShareCount.removeWhere((key, value) => key != today);
      await prefs.setString('daily_share_count', json.encode(dailyShareCount));
    }

    return dailyShareCount[today] ?? 0;
  }

  Future<void> _incrementShareCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayDateString();
    Map<String, int> dailyShareCount = Map<String, int>.from(
        json.decode(prefs.getString('daily_share_count') ?? '{}'));

    // Clean up old dates
    dailyShareCount.removeWhere((key, value) => key != today);

    dailyShareCount[today] = (dailyShareCount[today] ?? 0) + 1;
    await prefs.setString('daily_share_count', json.encode(dailyShareCount));
  }

  Future<void> _shareImage() async {
    setState(() {
      isProcessing = true;
      progressMessage = "Preparing image for sharing...";
    });

    try {
      final shareCount = await _getShareCount();
      final limit = appStore.planLimits.getLimit('share_poster_daily');

      if (shareCount >= limit) {
        _showUpgradePopup(isShare: true);
        return;
      }
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Unable to capture frame.');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/shared_frame_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes!);

      final ShareResult result = await Share.shareXFiles(
        [XFile(filePath)],
        text: 'AJ Hub Mobile App !',
      );

      if (result.status == ShareResultStatus.success) {
        await _incrementShareCount();
      }
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
        elevation: 0,
        title: Text(
          'Select Frame',
          style: GoogleFonts.b612(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(4.0),
            // Set the size of the container. Adjust as needed.
            width: 36.0,
            height: 35.0,
            decoration: BoxDecoration(
              // The border property defines the outline
              border: Border.all(
                color: Colors.red, // Set the border color to red
                width: 1.3, // Set the thickness of the border
              ),
              // The borderRadius makes the corners rounded. Use 0 for sharp corners.
              borderRadius:
                  BorderRadius.circular(8.0), // Creates rounded corners
            ),
            child: IconButton(
              // Use padding: EdgeInsets.zero to remove default IconButton padding
              // so the icon centers perfectly inside our container.
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.edit,
                size: 21.0,
                color: Colors.red,
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
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(4.0),
            // Set the size of the container. Adjust as needed.
            width: 36.0,
            height: 35.0,
            decoration: BoxDecoration(
              // The border property defines the outline
              border: Border.all(
                color: Colors.red, // Set the border color to red
                width: 1.3, // Set the thickness of the border
              ),
              // The borderRadius makes the corners rounded. Use 0 for sharp corners.
              borderRadius:
                  BorderRadius.circular(8.0), // Creates rounded corners
            ),
            child: IconButton(
              icon: const Icon(
                Icons.file_download,
                size: 21.0,
                color: Colors.red,
              ),
              tooltip: 'Download Image',
              onPressed: !isProcessing ? _downloadImage : null,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(4.0),
            // Set the size of the container. Adjust as needed.
            width: 36.0,
            height: 35.0,
            decoration: BoxDecoration(
              // The border property defines the outline
              border: Border.all(
                color: Colors.red, // Set the border color to red
                width: 1.3, // Set the thickness of the border
              ),
              // The borderRadius makes the corners rounded. Use 0 for sharp corners.
              borderRadius:
                  BorderRadius.circular(8.0), // Creates rounded corners
            ),
            child: IconButton(
              icon: const Icon(
                Icons.share,
                size: 21.0,
                color: Colors.red,
              ),
              tooltip: 'Share Image',
              onPressed: !isProcessing ? _shareImage : null,
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
                              placeholder: (context, url) => const Center(
                                  child:
                                      CircularProgressIndicator()), // Show loading indicator while the image is being loaded
                              errorWidget: (context, url, error) =>
                                  Image.asset('assets/images/app_logo.png'),
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
                            controller:
                                PageController(initialPage: selectedFrameIndex),
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
                SizedBox(height: 20.h),
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
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/images/app_logo.png'),
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
                    Text(progressMessage,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

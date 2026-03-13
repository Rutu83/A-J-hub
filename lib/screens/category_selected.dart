import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ajhub_app/dynamic_fram/fram_1.dart';
import 'package:ajhub_app/dynamic_fram/fram_2.dart';
import 'package:ajhub_app/dynamic_fram/fram_3.dart';
import 'package:ajhub_app/dynamic_fram/fram_4.dart';
import 'package:ajhub_app/dynamic_fram/fram_5.dart';
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
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/utils/configs.dart';

import 'business_form.dart';
import 'package:shimmer/shimmer.dart';

class CategorySelected extends StatefulWidget {
  final List<String> imagePaths;
  final String title;

  const CategorySelected(
      {super.key, required this.imagePaths, required this.title});

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
  String status = ' ';
  String mobileNumber = ' ';
  String address = ' ';
  String website = ' ';
  List<Widget> frameWidgets = [];
  bool isLoading = true;
  bool isProcessing = false;
  String progressMessage = "";
  final GlobalKey _repaintKey = GlobalKey();

  String? businessLogoUrl;
  Offset logoPosition = const Offset(15, 15);
  double logoScale = 0.6;
  double _baseScale = 0.6;
  bool showLogo = false;

  List<String> _validImagePaths = [];

  @override
  void initState() {
    super.initState();
    _validateAndSetImagePaths();

    if (_validImagePaths.isNotEmpty) {
      // Don't block the UI. Fetch data in background.
      fetchUserData();
      printActiveBusinessData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _isUrlSupported(String? url) {
    if (url == null || url.isEmpty) return false;
    final lowercasedUrl = url.toLowerCase();
    if (lowercasedUrl.endsWith('.avif') ||
        lowercasedUrl.endsWith('.heic') ||
        lowercasedUrl.endsWith('.heif')) {
      if (kDebugMode) {
        print('Unsupported image format skipped: $url');
      }
      return false;
    }
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasAbsolutePath && uri.scheme.startsWith('http');
  }

  void _validateAndSetImagePaths() {
    setState(() {
      _validImagePaths = widget.imagePaths.where(_isUrlSupported).toList();
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  // Checks current business count against the plan limit and navigates accordingly.
  // Called when user has no active business stored — prompts them to add one.
  void _showAddBusinessPopup() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text('Add Your Business',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Text(
                'To create posters with your own details, please add your business information first.',
                style: GoogleFonts.poppins()),
            actions: <Widget>[
              TextButton(
                child: const Text('Maybe Later'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();

                  // ✅ PLAN LIMIT CHECK — mirrors FeatureGate._hasAccess() logic exactly:
                  //   inactive user → trial limit of 1 (matches FeatureGate hardcoded trial logic)
                  //   active user   → read plan limit; 0 means feature is blocked entirely
                  try {
                    final response = await http.get(
                      Uri.parse('${BASE_URL}getbusinessprofile'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ${appStore.token}',
                      },
                    );
                    int currentCount = 0;
                    if (response.statusCode == 200) {
                      final data =
                          (json.decode(response.body)['data'] as List?);
                      currentCount = data?.length ?? 0;
                    }

                    bool allowed;
                    if (appStore.Status == 'inactive') {
                      // Trial: max 1 business (same as FeatureGate trial logic)
                      allowed = currentCount < 1;
                    } else {
                      final limit =
                          appStore.planLimits.getLimit('add_business');
                      // limit=0 → feature blocked entirely (don't fallback)
                      allowed = limit > 0 && currentCount < limit;
                    }

                    if (!allowed) {
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LockedFeatureScreen(
                              featureName: 'Add Business',
                              description:
                                  'You have reached your plan limit for adding businesses. Upgrade your plan to add more.',
                              icon: Icons.business,
                            ),
                          ),
                        );
                      }
                      return;
                    }
                  } catch (_) {
                    // If API fails, allow navigation (fail open for UX)
                  }

                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BusinessForm()),
                    );
                  }
                },
                child: const Text('Add Details'),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> printActiveBusinessData() async {
    // We don't set isLoading = true here because we want the grid to show immediately.
    // We only track it for the Frame Preview section.
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
          String? potentialLogoUrl = activeBusiness['logo'];
          if (_isUrlSupported(potentialLogoUrl)) {
            businessLogoUrl = potentialLogoUrl;
            showLogo = true;
          } else {
            businessLogoUrl = null;
            showLogo = false;
          }
        });
      } else {
        // --- NEW CODE ADDED: This line calls the new popup function ---
        _showAddBusinessPopup();

        // (Your existing code remains untouched)
        setState(() {
          businessName = 'Aj hub Mobile App';
          ownerName = 'Aj hub Mobile App';
          mobileNumber = '78630 45542';
          emailAddress = 'support@ajhub.co.in';
          address = 'Palanpur , Gujarat - 385001';
          website = 'https://ajhub.co.in';
          businessLogoUrl = null;
          showLogo = false;
        });
      }
      await _loadFrames();
    } catch (error) {
      if (!mounted) return;
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
    final allFrames = [
      Fram1(
          businessName: businessName,
          phoneNumber: mobileNumber,
          emailAddress: emailAddress,
          address: address,
          website: website),
      Fram2(
          businessName: businessName,
          phoneNumber: mobileNumber,
          emailAddress: emailAddress,
          address: address,
          website: website),
      Fram3(
          businessName: businessName,
          phoneNumber: mobileNumber,
          emailAddress: emailAddress,
          address: address,
          website: website),
      Fram4(
          businessName: businessName,
          phoneNumber: mobileNumber,
          emailAddress: emailAddress,
          address: address,
          website: website),
      Fram5(
          businessName: businessName,
          phoneNumber: mobileNumber,
          emailAddress: emailAddress,
          address: address,
          website: website),
    ];

    // Get the limit, defaulting to 1 if not set (or 2 for basic if that was default)
    // The backend provides the exact number.
    final limit = appStore.planLimits.getLimit('business_frame');
    final actualLimit =
        limit > 0 ? limit : 2; // Fallback to 2 basic frames if limit is 0/unset

    frameWidgets = allFrames.take(actualLimit).toList();

    if (mounted) {
      setState(() {
        // Reset selected index if the new limits shrink the array too much
        if (selectedFrameIndex >= frameWidgets.length) {
          selectedFrameIndex = 0;
        }
      });
    }
  }

  // (The rest of your file remains exactly the same...)
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

    _showDownloads(); // Keeping this as it seems to just read paths
    return dailyDownloadCount[today] ?? 0;
  }

  Future<void> _showDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> downloadedPaths =
        json.decode(prefs.getString('downloaded_paths') ?? '{}');
    Map<String, List<String>> downloadedPathsSafe = downloadedPaths
        .map((key, value) => MapEntry(key, List<String>.from(value ?? [])));
    List<String> pathsForTitle = downloadedPathsSafe[widget.title] ?? [];
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
        if (!mounted) return;
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
      if (!mounted) return;
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
        text: 'AJ HUb Mobile App!',
      );

      if (result.status == ShareResultStatus.success) {
        await _incrementShareCount();
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error sharing image: $error");
      }
      if (!mounted) return;
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

  // --- NEW: Shimmer Widget for Frame Preview ---
  Widget _buildFrameShimmer(double containerWidth) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: containerWidth,
        width: containerWidth,
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Helper method to keep build clean
  Widget _buildBody(double containerWidth) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              if (isLoading)
                _buildFrameShimmer(containerWidth)
              else
                RepaintBoundary(
                  key: _repaintKey,
                  child: LayoutBuilder(builder: (context, constraints) {
                    const double logoBaseSize = 80.0;
                    return SizedBox(
                      height: containerWidth,
                      width: containerWidth,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: _validImagePaths[selectedIndex],
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/images/app_logo.png'),
                              ),
                            ),
                          ),
                          PageView.builder(
                            itemCount: frameWidgets.length,
                            controller:
                                PageController(initialPage: selectedFrameIndex),
                            onPageChanged: (index) {
                              setState(() {
                                selectedFrameIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return frameWidgets.isEmpty
                                  ? const SizedBox.shrink()
                                  : frameWidgets[index];
                            },
                          ),
                          if (showLogo && businessLogoUrl != null)
                            Positioned(
                              left: logoPosition.dx,
                              top: logoPosition.dy,
                              child: GestureDetector(
                                onScaleStart: (details) {
                                  _baseScale = logoScale;
                                },
                                onScaleUpdate: (details) {
                                  setState(() {
                                    logoScale = (_baseScale * details.scale)
                                        .clamp(0.5, 2.0);

                                    final currentLogoWidth =
                                        logoBaseSize * logoScale;
                                    final currentLogoHeight =
                                        logoBaseSize * logoScale;

                                    double newDx = logoPosition.dx +
                                        details.focalPointDelta.dx;
                                    double newDy = logoPosition.dy +
                                        details.focalPointDelta.dy;

                                    newDx = newDx.clamp(
                                        0.0,
                                        constraints.maxWidth -
                                            currentLogoWidth);
                                    newDy = newDy.clamp(
                                        0.0,
                                        constraints.maxHeight -
                                            currentLogoHeight);

                                    logoPosition = Offset(newDx, newDy);
                                  });
                                },
                                child: Transform.scale(
                                  scale: logoScale,
                                  child: SizedBox(
                                    width: logoBaseSize,
                                    height: logoBaseSize,
                                    child: CachedNetworkImage(
                                      imageUrl: businessLogoUrl!,
                                      placeholder: (context, url) => Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      fit: BoxFit.contain,
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              'assets/images/app_logo.png'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600
                      ? 5
                      : 3, // Responsive!
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _validImagePaths.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: selectedIndex == index
                            ? Border.all(color: Colors.red, width: 2)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: _validImagePaths[index],
                          fit: BoxFit.cover,
                          memCacheHeight:
                              400, // Optimization: Resize active image
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              Image.asset('assets/images/app_logo.png'),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 100.h), // Space for bottom content
            ],
          ),
        ),
        if (isProcessing)
          Container(
            color: Colors.black.withOpacity(0.55),
            child: Center(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[700]!,
                highlightColor: Colors.grey[300]!,
                child: Container(
                  width: 200,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 14,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 10,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final containerWidth = MediaQuery.of(context).size.width * 0.97;
    if (_validImagePaths.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _validImagePaths.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'No supported images found for this category.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 16.sp, color: Colors.grey[700]),
                  ),
                ),
              )
            : _buildBody(containerWidth), // Extracted body construction
      );
    }
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
            margin: const EdgeInsets.all(4.0),
            width: 36.0,
            height: 35.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.edit,
                size: 21.0,
                color: Colors.red,
              ),
              tooltip: 'Edit Business Details',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryEditBusinessForm(),
                  ),
                ).then((_) {
                  printActiveBusinessData();
                });
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4.0),
            width: 36.0,
            height: 35.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(8.0),
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
            margin: const EdgeInsets.all(4.0),
            width: 36.0,
            height: 35.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(8.0),
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
                // --- FRAME PREVIEW SECTION (With Shimmer) ---
                if (isLoading)
                  _buildFrameShimmer(containerWidth)
                else
                  RepaintBoundary(
                    key: _repaintKey,
                    child: LayoutBuilder(builder: (context, constraints) {
                      const double logoBaseSize = 80.0;
                      return SizedBox(
                        height: containerWidth,
                        width: containerWidth,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: _validImagePaths[selectedIndex],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.asset('assets/images/app_logo.png'),
                                ),
                              ),
                            ),
                            PageView.builder(
                              itemCount: frameWidgets.length,
                              controller: PageController(
                                  initialPage: selectedFrameIndex),
                              onPageChanged: (index) {
                                setState(() {
                                  selectedFrameIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return frameWidgets.isEmpty
                                    ? const SizedBox.shrink()
                                    : frameWidgets[index];
                              },
                            ),
                            if (showLogo && businessLogoUrl != null)
                              Positioned(
                                left: logoPosition.dx,
                                top: logoPosition.dy,
                                child: GestureDetector(
                                  onScaleStart: (details) {
                                    _baseScale = logoScale;
                                  },
                                  onScaleUpdate: (details) {
                                    setState(() {
                                      logoScale = (_baseScale * details.scale)
                                          .clamp(0.5, 2.0);

                                      final currentLogoWidth =
                                          logoBaseSize * logoScale;
                                      final currentLogoHeight =
                                          logoBaseSize * logoScale;

                                      double newDx = logoPosition.dx +
                                          details.focalPointDelta.dx;
                                      double newDy = logoPosition.dy +
                                          details.focalPointDelta.dy;

                                      newDx = newDx.clamp(
                                          0.0,
                                          constraints.maxWidth -
                                              currentLogoWidth);
                                      newDy = newDy.clamp(
                                          0.0,
                                          constraints.maxHeight -
                                              currentLogoHeight);

                                      logoPosition = Offset(newDx, newDy);
                                    });
                                  },
                                  child: Transform.scale(
                                    scale: logoScale,
                                    child: SizedBox(
                                      width: logoBaseSize,
                                      height: logoBaseSize,
                                      child: CachedNetworkImage(
                                        imageUrl: businessLogoUrl!,
                                        placeholder: (context, url) =>
                                            Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        fit: BoxFit.contain,
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                                'assets/images/app_logo.png'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
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
                  itemCount: _validImagePaths.length,
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
                                imageUrl: _validImagePaths[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(color: Colors.white),
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/images/app_logo.png'),
                              ),
                            ),
                          ),
                          if (selectedIndex == index)
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.red,
                                  size: 24,
                                ),
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
              color: Colors.black.withOpacity(0.55),
              child: Center(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[700]!,
                  highlightColor: Colors.grey[300]!,
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 10,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

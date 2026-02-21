import 'dart:convert'; // Required for json.decode
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ajhub_app/model/subcategory_model.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Required for SharedPreferences

// --- FRAME DATA MODEL (No changes) ---
class Frame {
  final int id;
  final String name;
  final String thumbnailAsset;

  const Frame({
    required this.id,
    required this.name,
    required this.thumbnailAsset,
  });
}

const List<Frame> availableFrames = [
  Frame(id: 1, name: 'Frame 1', thumbnailAsset: 'assets/frames/frame_1.png'),
  Frame(id: 2, name: 'Frame 2', thumbnailAsset: 'assets/frames/frame_2.png'),
  Frame(id: 3, name: 'Frame 3', thumbnailAsset: 'assets/frames/frame_3.png'),
];

// --- MAIN PAGE WIDGET (STATEFUL) ---
class PersonalCardPage extends StatefulWidget {
  const PersonalCardPage({super.key});

  @override
  State<PersonalCardPage> createState() => _PersonalCardPageState();
}

class _PersonalCardPageState extends State<PersonalCardPage> {
  // --- STATE MANAGEMENT ---
  final TextEditingController _searchController = TextEditingController();
  List<Subcategory> _allSubcategories = [];
  List<Subcategory> _filteredSubcategories = [];
  Subcategory? _selectedSubcategory;

  bool isProcessing = false;
  final GlobalKey _repaintKey = GlobalKey();
  bool _isProcessing = false; // Duplicate flag, keeping for minimal diff
  String _progressMessage = "";

  bool isLoading = true;
  String? _error;
  bool _isSearchVisible = false;

  // Business Data
  String businessName = '';
  String ownerName = '';
  String mobileNumber = '';
  String emailAddress = '';
  String address = '';
  String website = '';
  String personal_photo = '';
  String? businessLogoUrl;

  // --- FILTERS DATA ---
  final List<String> _filters = [
    "All",
    "Chanakya Niti",
    "Daily Use Quotes",
    "Business",
    "Entrepreneurship",
    "Good Morning",
    "Good Night",
    "Gujarati Suvichar",
    "Hindi Quotes",
    "Hindi Suvichar",
    "Leader Quotes",
    "Love Quotes",
    "Motivational",
    "Positive Vibes",
    "Sad Quotes",
    "Shayri",
    "Sports",
  ];
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchInitialData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() => isLoading = true);
    await Future.wait([
      _fetchSubcategories(),
      _fetchBusinessData(),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> _fetchSubcategories() async {
    try {
      final response = await getAllSubCategories();
      if (mounted) {
        setState(() {
          _allSubcategories = response.subcategories;
        });
        _applyFilters(); // Apply filters to generate "All" option initially
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  // --- LOGO: Helper function to check for unsupported image formats ---
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

  Future<void> _fetchBusinessData() async {
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
          personal_photo = activeBusiness['personal_photo'] ?? 'Not Provided';

          String? potentialLogoUrl = activeBusiness['logo'];
          if (_isUrlSupported(potentialLogoUrl)) {
            businessLogoUrl = potentialLogoUrl;
          } else {
            businessLogoUrl = null;
          }
        });
      } else {
        // Default Data
        setState(() {
          businessName = 'Aj hub Mobile App';
          ownerName = 'Aj hub Mobile App';
          mobileNumber = '78630 45542';
          emailAddress = 'support@ajhub.co.in';
          address = 'Palanpur , Gujarat - 385001';
          website = 'https://ajhub.co.in';
          businessLogoUrl = null;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading business data: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        FocusScope.of(context).unfocus();
        _searchController.clear();
      }
    });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    final categoryFilter = _filters[_selectedFilterIndex];

    final filteredList = _allSubcategories.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(query);
      final matchesCategory = categoryFilter == "All" ||
          item.name.toLowerCase().contains(categoryFilter.toLowerCase());
      return matchesSearch && matchesCategory;
    }).toList();

    setState(() {
      _filteredSubcategories = filteredList;

      // Reset selection when filters change (null means "Show All")
      _selectedSubcategory = null;
    });
  }

  void _onSubcategorySelected(Subcategory subcategory) {
    setState(() {
      // Toggle selection: if already selected, deselect to show "All"
      if (_selectedSubcategory == subcategory) {
        _selectedSubcategory = null;
      } else {
        _selectedSubcategory = subcategory;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : Column(
              children: [
                _buildFilterTabs(), // NEW Filter Tabs
                if (_filteredSubcategories.isEmpty)
                  const Expanded(
                    child: Center(child: Text('No subcategories found.')),
                  )
                else ...[
                  _buildSubcategoryList(_filteredSubcategories),
                  Expanded(
                    child: _buildImagePosterList(),
                  ),
                ],
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.red,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: _isSearchVisible
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _toggleSearch,
            )
          : null, // Default
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final offsetAnimation =
              Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .animate(animation);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        child: _isSearchVisible
            ? _buildSearchField()
            : Text(
                'Personal Poster',
                key: const ValueKey('title'),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
      ),
      actions: [
        if (!_isSearchVisible)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _toggleSearch,
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      key: const ValueKey('searchField'),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.9)),
          contentPadding: const EdgeInsets.only(top: 5),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50.h,
      color: Colors.grey[50],
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
                _applyFilters();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? Colors.red : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                _filters[index],
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubcategoryList(List<Subcategory> subcategories) {
    return Container(
      height: 155, // Increased height to prevent overflow
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          final subcategory = subcategories[index];
          final isSelected = subcategory == _selectedSubcategory;
          final imageUrl = subcategory.images.isNotEmpty
              ? subcategory.images.first
              : 'https://placehold.co/100x100/CCCCCC/FFFFFF?text=N/A';

          return GestureDetector(
            onTap: () => _onSubcategorySelected(subcategory),
            child: Container(
              width: 85, // Fixed width
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Container(
                    width: 70, // Fixed size
                    height: 70, // Fixed size
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.red, width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) =>
                            Image.asset('assets/images/app_logo.png'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subcategory.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12, // Fixed font size
                      color: isSelected ? Colors.red : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePosterList() {
    // If no category selected, show ALL images from filtered subcategories
    final List<String> imagesToShow;
    if (_selectedSubcategory == null) {
      imagesToShow = _filteredSubcategories.expand((s) => s.images).toList();
    } else {
      imagesToShow = _selectedSubcategory!.images;
    }

    if (imagesToShow.isEmpty) {
      return const Center(
        child: Text('No images found.',
            style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: imagesToShow.length,
      itemBuilder: (context, index) {
        final imageUrl = imagesToShow[index];
        return PosterCard(
          posterImageUrl: imageUrl,
          personal_photo: personal_photo,
          ownerName: ownerName,
          mobileNumber: mobileNumber,
          emailAddress: emailAddress,
          businessLogoUrl: businessLogoUrl,
        );
      },
    );
  }
}

// --- REUSABLE POSTER CARD WIDGET (UPDATED) ---
class PosterCard extends StatefulWidget {
  final String posterImageUrl;
  final String personal_photo;
  final String ownerName;
  final String mobileNumber;
  final String emailAddress;
  final String? businessLogoUrl;

  const PosterCard({
    super.key,
    required this.posterImageUrl,
    required this.personal_photo,
    required this.ownerName,
    required this.mobileNumber,
    required this.emailAddress,
    this.businessLogoUrl,
  });

  @override
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard> {
  late final PageController _pageController;
  late Frame _selectedFrame;
  final GlobalKey _repaintKey = GlobalKey();
  bool _isProcessing = false;
  String _progressMessage = "";

  // --- LOGO: State variables for logo drag/scale ---
  Offset logoPosition = const Offset(15, 15);
  double logoScale = 0.6;
  double _baseScale = 0.6;
  Offset _panStartOffset = Offset.zero;
  bool showLogo = false;

  @override
  void initState() {
    super.initState();
    _selectedFrame = availableFrames.first;
    _pageController = PageController();
    showLogo = widget.businessLogoUrl != null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _captureWidgetAsImage() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Could not find the boundary to capture.');
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error capturing widget: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error capturing image: $e'),
            backgroundColor: Colors.red),
      );
      return null;
    }
  }

  Future<void> _downloadImage() async {
    setState(() {
      _isProcessing = true;
      _progressMessage = "Downloading image...";
    });

    try {
      final pngBytes = await _captureWidgetAsImage();
      if (pngBytes == null) throw Exception('Failed to capture image.');

      final directory = Directory('/storage/emulated/0/Pictures/AJHUB');
      if (!directory.existsSync()) directory.createSync(recursive: true);

      final filePath =
          '${directory.path}/poster_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await GallerySaver.saveImage(filePath, albumName: 'MyPosters');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error downloading image: $error'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isProcessing = false;
        _progressMessage = "";
      });
    }
  }

  Future<void> _shareImage() async {
    setState(() {
      _isProcessing = true;
      _progressMessage = "Preparing image for sharing...";
    });

    try {
      final pngBytes = await _captureWidgetAsImage();
      if (pngBytes == null) throw Exception('Failed to capture image data.');

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/shared_poster.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Created with AJ Hub Mobile App!',
        subject: 'Check out my new poster!',
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error sharing image: $error'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isProcessing = false;
        _progressMessage = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 8,
      margin: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainContent(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return RepaintBoundary(
      key: _repaintKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // PART 1: The Image Area (Square 1:1)
          AspectRatio(
            aspectRatio: 1 / 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double logoBaseSize = 80.0;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Stack(
                      fit: StackFit.expand,
                      children: [
                        ImageFiltered(
                          imageFilter:
                              ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: CachedNetworkImage(
                            imageUrl: widget.posterImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[200]),
                            errorWidget: (context, url, error) =>
                                Image.asset('assets/images/app_logo.png'),
                          ),
                        ),
                        Container(color: Colors.black.withOpacity(0.1)),
                        CachedNetworkImage(
                          imageUrl: widget.posterImageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) =>
                              Container(color: Colors.transparent),
                          errorWidget: (context, url, error) =>
                              Image.asset('assets/images/app_logo.png'),
                        ),
                      ],
                    ),
                    if (showLogo)
                      Positioned(
                        left: logoPosition.dx,
                        top: logoPosition.dy,
                        child: GestureDetector(
                          onScaleStart: (details) {
                            _baseScale = logoScale;
                            _panStartOffset = details.focalPoint;
                          },
                          onScaleUpdate: (details) {
                            setState(() {
                              if (details.scale != 1.0) {
                                logoScale = (_baseScale * details.scale)
                                    .clamp(0.5, 2.0);
                              }
                              final panDelta =
                                  details.focalPoint - _panStartOffset;
                              _panStartOffset = details.focalPoint;

                              final currentLogoWidth = logoBaseSize * logoScale;
                              final currentLogoHeight =
                                  logoBaseSize * logoScale;

                              double newDx = logoPosition.dx + panDelta.dx;
                              double newDy = logoPosition.dy + panDelta.dy;

                              newDx = newDx.clamp(
                                  0.0, constraints.maxWidth - currentLogoWidth);
                              newDy = newDy.clamp(0.0,
                                  constraints.maxHeight - currentLogoHeight);

                              logoPosition = Offset(newDx, newDy);
                            });
                          },
                          child: Transform.scale(
                            scale: logoScale,
                            child: SizedBox(
                              width: logoBaseSize,
                              height: logoBaseSize,
                              child: CachedNetworkImage(
                                imageUrl: widget.businessLogoUrl!,
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/images/app_logo.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          // PART 2: The Footer Frame (Contact Info)
          SizedBox(
            height: 90.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: availableFrames.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedFrame = availableFrames[index];
                });
              },
              itemBuilder: (context, index) {
                final frame = availableFrames[index];
                return _buildFrameFromId(frame.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(12.w),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _downloadImage,
              icon: const Icon(Icons.download, color: Colors.white),
              label:
                  const Text('Download', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                disabledBackgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r)),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isProcessing ? null : _shareImage,
              icon: const Icon(Icons.share),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                disabledForegroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: BorderSide(
                    color: _isProcessing
                        ? Colors.grey.shade300
                        : Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.black, size: 14.sp),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(text,
              style: TextStyle(color: Colors.black, fontSize: 12.sp),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildFrameFromId(int id) {
    switch (id) {
      case 1:
        return _buildFrame1();
      case 2:
        return _buildFrame2();
      case 3:
        return _buildFrame3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFrame1() {
    return Container(
      height: 90.h,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: CachedNetworkImage(
                imageUrl: widget.personal_photo,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/images/app_logo.png'),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactInfo(Icons.phone_rounded, widget.mobileNumber),
                  SizedBox(height: 8.h),
                  _buildContactInfo(Icons.email_rounded, widget.emailAddress),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrame2() {
    return Container(
      height: 90.h,
      color: Colors.white,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 20.w, color: Colors.red)),
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 30.w),
            child: Row(
              children: [
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: widget.personal_photo,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images/app_logo.png'),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.ownerName,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 16.sp)),
                        Text(widget.mobileNumber,
                            style: GoogleFonts.poppins(
                                fontSize: 12.sp, color: Colors.grey[700])),
                        Text(widget.emailAddress,
                            style: GoogleFonts.poppins(
                                fontSize: 12.sp, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFrame3() {
    return Container(
      height: 90.h,
      color: Colors.red.shade50,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.phone_iphone_rounded,
                        color: Colors.red, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(widget.mobileNumber,
                        style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp)),
                  ]),
                  SizedBox(height: 8.h),
                  Row(children: [
                    Icon(Icons.mail_outline_rounded,
                        color: Colors.red, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(widget.emailAddress,
                        style: GoogleFonts.poppins(
                            color: Colors.red, fontSize: 13.sp),
                        overflow: TextOverflow.ellipsis),
                  ]),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: CachedNetworkImage(
                imageUrl: widget.personal_photo,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/images/app_logo.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

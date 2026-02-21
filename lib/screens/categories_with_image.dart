import 'package:ajhub_app/model/subcategory_model.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/category_selected.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart'; // Import Shimmer package

// --- MAIN SCREEN WIDGET ---

class SubcategoriesScreen extends StatefulWidget {
  const SubcategoriesScreen({super.key});

  @override
  State<SubcategoriesScreen> createState() => _SubcategoriesScreenState();
}

class _SubcategoriesScreenState extends State<SubcategoriesScreen>
    with AutomaticKeepAliveClientMixin {
  // --- STATE MANAGEMENT ---
  final TextEditingController _searchController = TextEditingController();

  List<Subcategory> _allSubcategories = [];
  List<Subcategory> _filteredSubcategories = [];

  bool _isLoading = true;
  String? _error;
  bool _isSearchVisible = false;

  // --- PAGINATION STATE ---
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _fetchData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData &&
        !_isLoading) {
      _loadMoreData();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMoreData = true;
      _allSubcategories.clear(); // Clear existing when pulling fresh
    });

    try {
      final response = await getAllSubCategories(page: 1);
      if (mounted) {
        setState(() {
          _allSubcategories = response.subcategories;
          _filteredSubcategories = response.subcategories;
          _isLoading = false;
          // Assume if we get less than PER_PAGE_ITEM or 0, no more data
          if (response.subcategories.isEmpty) {
            _hasMoreData = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await getAllSubCategories(page: nextPage);
      if (mounted) {
        setState(() {
          if (response.subcategories.isEmpty) {
            _hasMoreData = false;
          } else {
            // Filter out duplicates based on name
            final existingNames = _allSubcategories.map((e) => e.name).toSet();
            final newItems = response.subcategories
                .where((item) => !existingNames.contains(item.name))
                .toList();

            if (newItems.isEmpty) {
              // If all items in this page were duplicates, we might assume there's no more *new* data
              // Or we could try to load the next page?
              // For now, let's just append nothing but keep _hasMoreData true in case the next page has new stuff.
              // Logic choice: Append unique items only.
            } else {
              _allSubcategories.addAll(newItems);
            }

            if (_searchController.text.isNotEmpty) {
              _onSearchChanged(); // Re-filter with new data
            } else {
              _filteredSubcategories = _allSubcategories;
            }
            _currentPage = nextPage;
          }
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          // Optionally show a snackbar for pagination error
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    _searchController.clear();
    await _fetchData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        // Dismiss keyboard for a smoother exit UX
        FocusScope.of(context).unfocus();
        _searchController.clear();
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.red,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _buildSliverAppBar(),
            _buildFilterTabs(), // Added Filter Tabs
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            _buildContentSliver(),
            if (_isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- NEW FILTER TABS UI ---
  final List<String> _filters = [
    "All",
    "Chanakya Niti",
    "Daily Use Quotes",
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

  Widget _buildFilterTabs() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50.h,
        margin: EdgeInsets.only(top: 16.h),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: _filters.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final isSelected = _selectedFilterIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                  _applyFilters(); // Apply filter on tap
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.grey.shade300,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  _filters[index],
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- UPDATED FILTER LOGIC ---
  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    final category = _filters[_selectedFilterIndex];

    setState(() {
      _filteredSubcategories = _allSubcategories.where((item) {
        final matchesSearch = item.name.toLowerCase().contains(query);
        // Simple string matching for now
        final matchesCategory = category == "All" ||
            item.name.toLowerCase().contains(category.toLowerCase());

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Widget _buildContentSliver() {
    if (_isLoading) {
      return _buildGridShimmer();
    }
    if (_error != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text('An error occurred: $_error')),
      );
    }
    if (_allSubcategories.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
            child: Text('No Subcategories Available.',
                style: TextStyle(fontSize: 16, color: Colors.grey))),
      );
    }
    if (_searchController.text.isNotEmpty && _filteredSubcategories.isEmpty) {
      return _buildNoResults();
    }
    // Use MediaQuery to determine responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount =
        screenWidth > 600 ? 5 : 3; // 5 for tablets, 3 for phones

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final subcategory = _filteredSubcategories[index];
            return SubcategoryCard(subcategory: subcategory);
          },
          childCount: _filteredSubcategories.length,
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      snap: false,
      elevation: 4.0,
      backgroundColor: Colors.red,
      // --- DEDICATED BACK BUTTON TO EXIT SEARCH MODE ---
      leading: _isSearchVisible
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _toggleSearch,
            )
          : null, // Shows default drawer/back button if not searching
      titleSpacing: 0, // Remove default spacing when search is active
      // --- ANIMATED TITLE / SEARCH BAR ---
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Slide and Fade transition for a professional feel
          final inAnimation =
              Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .animate(animation);
          final outAnimation =
              Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                  .animate(animation);

          if (child.key == const ValueKey('searchField')) {
            return ClipRect(
              child: SlideTransition(
                position: inAnimation,
                child: FadeTransition(opacity: animation, child: child),
              ),
            );
          } else {
            return ClipRect(
              child: SlideTransition(
                position: outAnimation,
                child: FadeTransition(opacity: animation, child: child),
              ),
            );
          }
        },
        child: _isSearchVisible
            ? _buildSearchField()
            : KeyedSubtree(
                key: const ValueKey('title'),
                child: Text(
                  '   Exclusive Category',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
      ),
      actions: [
        // --- The search icon only shows when the title is visible ---
        if (!_isSearchVisible)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _toggleSearch,
          ),
      ],
    );
  }

  // --- NEW PROFESSIONAL SEARCH FIELD UI ---
  Widget _buildSearchField() {
    return Container(
      key: const ValueKey('searchField'),
      height: 40.h,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.9)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
        onChanged: (query) => setState(() {}),
      ),
    );
  }

  Widget _buildNoResults() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80.sp, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text(
                "No Results Found",
                style: GoogleFonts.poppins(
                    fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Text(
                "We couldn't find any items matching your search.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridShimmer() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 5 : 3;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      sliver: SliverToBoxAdapter(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.75,
            ),
            itemCount: crossAxisCount * 3, // Show enough rows
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Ensure full width
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      height: 12.h,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// --- SUPPORTING WIDGETS ---

class SubcategoryCard extends StatefulWidget {
  final Subcategory subcategory;

  const SubcategoryCard({super.key, required this.subcategory});

  @override
  State<SubcategoryCard> createState() => _SubcategoryCardState();
}

class _SubcategoryCardState extends State<SubcategoryCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure KeepAlive logic runs
    final imageUrl = widget.subcategory.images.isNotEmpty
        ? widget.subcategory.images[0]
        : '';
    return GestureDetector(
      onTap: () {
        if (widget.subcategory.images.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelected(
              imagePaths: widget.subcategory.images,
              title: widget.subcategory.name,
            ),
          ),
        );
      },
      child: Container(
        // The container now handles clipping its children to the border shape.
        clipBehavior: Clip.antiAlias, // This is a key improvement!
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r), // Softer corners
          // --- REFINED BORDER ---
          border: Border.all(
            color: Colors.grey.shade300, // Subtler border color
            width: 1.0, // Thinner border
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Softer shadow
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              // We no longer need a ClipRRect here because the parent Container handles it.
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images/app_logo.png'),
                    )
                  else
                    Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  // The gradient overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4)
                      ],
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                    )),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                widget.subcategory.name,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

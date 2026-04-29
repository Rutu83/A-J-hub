import 'package:ajhub_app/model/categories_subcategories_modal .dart';
import 'package:ajhub_app/model/custom_template_model.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/ai/ai_image_generator_screen.dart';
import 'package:ajhub_app/screens/blank_template_editor_screen.dart';
import 'package:ajhub_app/screens/category_see_all_screen.dart';
import 'package:ajhub_app/screens/collage_maker_screen.dart';
import 'package:ajhub_app/screens/editor/photo_editor_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

// ─── Trending feature model ───────────────────────────────────────────────────
class _TrendingItem {
  final IconData icon;
  final String label;
  final bool badge; // whether to show "SOON" badge
  const _TrendingItem(this.icon, this.label, {this.badge = false});
}

class CustomEditCategoryScreen extends StatefulWidget {
  const CustomEditCategoryScreen({super.key});

  @override
  State<CustomEditCategoryScreen> createState() =>
      _CustomEditCategoryScreenState();
}

class _CustomEditCategoryScreenState extends State<CustomEditCategoryScreen> with AutomaticKeepAliveClientMixin {
  late Future<CategoriesWithSubcategoriesResponse> _categoriesFuture;

  // Cache template futures so they aren't re-fetched when navigating back
  final Map<int, Future<CustomTemplateResponse>> _templateFutureCache = {};

  Future<CustomTemplateResponse> _getTemplatesFuture(int subcategoryId) {
    return _templateFutureCache.putIfAbsent(
      subcategoryId,
      () => getCustomTemplates(subcategoryId),
    );
  }

  static const List<_TrendingItem> _trending = [
    _TrendingItem(Icons.add_photo_alternate_outlined, 'Create Your\nOwn'),
    _TrendingItem(Icons.grid_view_rounded, 'Collage\nMaker'),
    _TrendingItem(Icons.auto_awesome, 'AI Image\nGenerator', badge: true),
    _TrendingItem(Icons.credit_card_outlined, 'Digital\nBusiness Card', badge: true),
    _TrendingItem(Icons.photo_size_select_actual_outlined, 'Frame\nStore', badge: true),
    _TrendingItem(Icons.contact_page_outlined, 'Visiting\nCard', badge: true),
  ];

  @override
  void initState() {
    super.initState();
    _categoriesFuture = getCustomEditCategories();
  }

  void _onTrendingTap(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BlankTemplateEditorScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CollageMakerScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiImageGeneratorScreen()),
        );
        break;
      default:
        // Coming soon items – show a brief snackbar
        final labels = ['Digital Business Card', 'Frame Store', 'Visiting Card'];
        final label = labels[index - 3];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚀 $label – Coming Soon!'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Custom',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final data = await _categoriesFuture.catchError((_) => CategoriesWithSubcategoriesResponse(categories: []));
              if (!mounted) return;
              showSearch(
                context: context,
                delegate: _CategorySearchDelegate(categories: data.categories),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<CategoriesWithSubcategoriesResponse>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Trending Features ──────────────────────────────────────
              SliverToBoxAdapter(child: _buildTrendingSection()),

              // ── API Categories ─────────────────────────────────────────
              if (snapshot.connectionState == ConnectionState.waiting)
                SliverToBoxAdapter(child: _buildCategoryShimmer())
              else if (snapshot.hasData && snapshot.data!.categories.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final cat = snapshot.data!.categories[i];
                      if (cat.subcategories.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _buildCategorySection(cat);
                    },
                    childCount: snapshot.data!.categories.length,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60.h),
                      child: Text(
                        'No categories available.',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 28.h)),
            ],
          );
        },
      ),
    );
  }

  // ─── Section Title (matches app pattern from trendingsection.dart) ────────
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          height: 24.h,
          width: 5.w,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ─── Trending Section ─────────────────────────────────────────────────────
  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: _buildSectionTitle('Trending Features'),
        ),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            physics: const BouncingScrollPhysics(),
            itemCount: _trending.length,
            itemBuilder: (ctx, i) => _buildTrendingTile(_trending[i], i),
          ),
        ),
        SizedBox(height: 12.h),
        Divider(height: 1, color: Colors.grey.withOpacity(0.18)),
      ],
    );
  }

  Widget _buildTrendingTile(_TrendingItem item, int index) {
    return GestureDetector(
      onTap: () => _onTrendingTap(index),
      child: SizedBox(
        width: 86.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 26.sp),
                ),
                if (item.badge)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'SOON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Category Section ─────────────────────────────────────────────────────
  Widget _buildCategorySection(CategoryWithSubcategory category) {
    return Padding(
      padding: EdgeInsets.only(bottom: 22.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle(category.name),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategorySeeAllScreen(category: category),
                      ),
                    );
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200.h,
            child: FutureBuilder<CustomTemplateResponse>(
              future: category.subcategories.isNotEmpty
                  ? _getTemplatesFuture(category.subcategories.first.id)
                  : Future.value(CustomTemplateResponse(status: false, message: '', data: [])),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildCardShimmerRow();
                }
                final templates = snapshot.data?.data ?? [];
                if (templates.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Center(
                      child: Text(
                        'No templates available',
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  physics: const BouncingScrollPhysics(),
                  itemCount: templates.length,
                  itemBuilder: (ctx, i) {
                    return _buildTemplateCard(templates[i]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(CustomTemplate template) {
    double ratio = template.canvasHeight > 0 
        ? template.canvasWidth / template.canvasHeight 
        : (766 / 1080);
    double dynamicWidth = 200.h * ratio;
    // ensure within sensible bounds so it doesn't break UI layout limits
    dynamicWidth = dynamicWidth.clamp(100.w, 350.w);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoEditorScreen(
              imageUrl: template.backgroundImageUrl,
              customTemplate: template,
            ),
          ),
        );
      },
      child: Container(
        width: dynamicWidth,
        margin: EdgeInsets.only(right: 12.w),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: _TemplateCardWidget(template: template),
      ),
    );
  }

  Widget _buildCardShimmerRow() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 120.w,
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }

  // ─── Shimmer placeholder ──────────────────────────────────────────────────
  Widget _buildCategoryShimmer() {
    return Column(
      children: List.generate(
        2,
        (_) => Padding(
          padding: EdgeInsets.only(bottom: 22.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 18.h,
                    width: 130.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 110.w,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 4,
                  itemBuilder: (_, __) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 110.w,
                      margin: EdgeInsets.only(right: 12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Template card with text-layer overlay ────────────────────────────────────
class _TemplateCardWidget extends StatelessWidget {
  final CustomTemplate template;
  const _TemplateCardWidget({required this.template});

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.black;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasW = template.canvasWidth.toDouble();
    final canvasH = template.canvasHeight.toDouble();

    return LayoutBuilder(builder: (ctx, constraints) {
      final viewW = constraints.maxWidth;
      final viewH = constraints.maxHeight;
      final scaleX = viewW / canvasW;
      final scaleY = viewH / canvasH;
      final s = scaleX > scaleY ? scaleX : scaleY; // match BoxFit.cover

      final dx = (viewW - canvasW * s) / 2;
      final dy = (viewH - canvasH * s) / 2;

      return CachedNetworkImage(
        imageUrl: template.backgroundImageUrl,
        memCacheWidth: 300,
        fadeInDuration: Duration.zero,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(color: Colors.white),
        ),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 18),
        ),
        imageBuilder: (context, imageProvider) {
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: Image(image: imageProvider, fit: BoxFit.cover),
              ),
              for (final layer in template.layers)
                if (layer.layerType == 'text')
                  Positioned(
                    left: dx + layer.posX * s,
                    top: dy + layer.posY * s,
                    child: FractionalTranslation(
                      translation: const Offset(-0.5, -0.5),
                      child: _buildTextLayer(layer, s),
                    ),
                  ),
              // Image layers
              for (final layer in template.layers)
                if (layer.layerType == 'image' && layer.imageUrl != null && layer.imageUrl!.isNotEmpty)
                  Positioned(
                    left: dx + (layer.posX - (layer.width ?? 200) / 2) * s,
                    top:  dy + (layer.posY - (layer.height ?? 200) / 2) * s,
                    child: CachedNetworkImage(
                      imageUrl: layer.imageUrl!,
                      width:  (layer.width  ?? 200) * s,
                      height: (layer.height ?? 200) * s,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                    ),
                  ),
            ],
          );
        },
      );
    });
  }

  Widget _buildTextLayer(CustomTemplateLayer layer, double scale) {
    final rawFontSize = (layer.fontSize ?? 24) * scale;
    final fontSize = rawFontSize.clamp(6.0, 40.0);
    final color = _parseColor(layer.colorHex);
    final fontFamily = layer.fontFamily;

    TextStyle style;
    try {
      style = GoogleFonts.getFont(
        fontFamily ?? 'Roboto',
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.w600,
      );
    } catch (_) {
      style = TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.w600,
      );
    }

    return Text(
      layer.defaultValue?.isNotEmpty == true
          ? layer.defaultValue!
          : layer.layerName,
      style: style,
      textAlign: TextAlign.center,
      softWrap: false, // Prevents unintended wrapping by removing strict bounding boxes
      maxLines: null,
    );
  }
}

// ─── Search Delegate ──────────────────────────────────────────────────────────
class _CategorySearchDelegate extends SearchDelegate<String> {
  final List<CategoryWithSubcategory> categories;

  _CategorySearchDelegate({required this.categories});

  @override
  String get searchFieldLabel => 'Search templates...';

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  List<_SearchResult> _getResults() {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    final results = <_SearchResult>[];
    for (final cat in categories) {
      if (cat.name.toLowerCase().contains(q)) {
        for (final sub in cat.subcategories) {
          results.add(_SearchResult(categoryName: cat.name, subcategoryName: sub.name, subcategoryId: sub.id));
        }
      }
      for (final sub in cat.subcategories) {
        if (sub.name.toLowerCase().contains(q)) {
          results.add(_SearchResult(categoryName: cat.name, subcategoryName: sub.name, subcategoryId: sub.id));
        }
      }
    }
    // Deduplicate
    final seen = <int>{};
    return results.where((r) => seen.add(r.subcategoryId)).toList();
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final results = _getResults();
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Type to search templates', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No results for "$query"', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final r = results[i];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.photo_library_outlined, color: Colors.red, size: 20),
          ),
          title: Text(r.subcategoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(r.categoryName, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            close(context, r.subcategoryName);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategorySeeAllScreen(
                  category: CategoryWithSubcategory(
                    id: 0,
                    name: r.categoryName,
                    subcategories: [Subcategory(id: r.subcategoryId, name: r.subcategoryName, images: [])],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SearchResult {
  final String categoryName;
  final String subcategoryName;
  final int subcategoryId;
  const _SearchResult({required this.categoryName, required this.subcategoryName, required this.subcategoryId});
}

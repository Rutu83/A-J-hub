import 'package:ajhub_app/model/categories_subcategories_modal%20.dart';
import 'package:ajhub_app/model/custom_template_model.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/editor/photo_editor_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class CategorySeeAllScreen extends StatefulWidget {
  final CategoryWithSubcategory category;

  const CategorySeeAllScreen({super.key, required this.category});

  @override
  State<CategorySeeAllScreen> createState() => _CategorySeeAllScreenState();
}

class _CategorySeeAllScreenState extends State<CategorySeeAllScreen> {
  late Future<List<CustomTemplate>> _allTemplatesFuture;

  @override
  void initState() {
    super.initState();
    _allTemplatesFuture = _fetchAllTemplates();
  }

  Future<List<CustomTemplate>> _fetchAllTemplates() async {
    final results = await Future.wait(
      widget.category.subcategories.map((sub) => getCustomTemplates(sub.id)),
    );
    return results.expand((r) => r.data).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          widget.category.name,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
          ),
        ),
      ),
      body: FutureBuilder<List<CustomTemplate>>(
        future: _allTemplatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerGrid();
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_search, size: 60.sp, color: Colors.grey[400]),
                  SizedBox(height: 14.h),
                  Text(
                    'No templates found',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
                  ),
                ],
              ),
            );
          }

          final templates = snapshot.data!;
          return GridView.builder(
            padding: EdgeInsets.all(16.w),
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.0,
            ),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return _buildTemplateCard(template);
            },
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard(CustomTemplate template) {
    final canvasW = template.canvasWidth.toDouble();
    final canvasH = template.canvasHeight.toDouble();

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: LayoutBuilder(builder: (ctx, constraints) {
          final scaleX = constraints.maxWidth / canvasW;
          final scaleY = constraints.maxHeight / canvasH;
          final s = scaleX > scaleY ? scaleX : scaleY; // match BoxFit.cover

          final dx = (constraints.maxWidth - canvasW * s) / 2;
          final dy = (constraints.maxHeight - canvasH * s) / 2;

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
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
            imageBuilder: (context, imageProvider) {
              return Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.hardEdge,
                children: [
                  Image(image: imageProvider, fit: BoxFit.cover),
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
                  // Image layer overlays
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
        }),
      ),
    );
  }

  Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.black;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.black;
    }
  }

  Widget _buildTextLayer(CustomTemplateLayer layer, double scale) {
    final rawFontSize = (layer.fontSize ?? 24) * scale;
    final fontSize = rawFontSize.clamp(4.0, 40.0);
    final color = _parseColor(layer.colorHex);

    TextStyle style;
    try {
      style = GoogleFonts.getFont(
        layer.fontFamily ?? 'Roboto',
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
      layer.defaultValue?.isNotEmpty == true ? layer.defaultValue! : layer.layerName,
      style: style,
      textAlign: TextAlign.center,
      softWrap: false,
      maxLines: null,
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.0,
      ),
      itemCount: 9,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(color: Colors.white),
        ),
      ),
    );
  }
}

import 'package:ajhub_app/model/custom_template_model.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/editor/photo_editor_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class CustomTemplateGalleryScreen extends StatefulWidget {
  final int subcategoryId;
  final String subcategoryName;

  const CustomTemplateGalleryScreen({
    super.key,
    required this.subcategoryId,
    required this.subcategoryName,
  });

  @override
  State<CustomTemplateGalleryScreen> createState() => _CustomTemplateGalleryScreenState();
}

class _CustomTemplateGalleryScreenState extends State<CustomTemplateGalleryScreen> {
  late Future<CustomTemplateResponse> _templatesFuture;

  @override
  void initState() {
    super.initState();
    _templatesFuture = getCustomTemplates(widget.subcategoryId);
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
          widget.subcategoryName,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
      body: FutureBuilder<CustomTemplateResponse>(
        future: _templatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.status || snapshot.data!.data.isEmpty) {
            return const Center(child: Text('No custom templates available here.'));
          }

          final templates = snapshot.data!.data;

          return GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14.h,
              crossAxisSpacing: 14.w,
              childAspectRatio: 766 / 1080, // match typical canvas ratio
            ),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoEditorScreen(
                        imageUrl: template.backgroundImageUrl,
                        customTemplate: template,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: _TemplatePreviewCard(template: template),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Template preview card with text-layer overlay ────────────────────────────
class _TemplatePreviewCard extends StatelessWidget {
  final CustomTemplate template;
  const _TemplatePreviewCard({required this.template});

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
            clipBehavior: Clip.hardEdge,
            children: [
              // Background image fills the card
              Positioned.fill(
                child: Image(image: imageProvider, fit: BoxFit.cover),
              ),
              // Text layer overlays scaled from canvas to thumbnail
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
              // Template name badge at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                    ),
                  ),
                  child: Text(
                    template.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
    final fontSize = rawFontSize.clamp(6.0, 56.0);
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
      softWrap: false,
      maxLines: null,
    );
  }
}

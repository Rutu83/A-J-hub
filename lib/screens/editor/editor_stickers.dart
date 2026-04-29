
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Builds the custom AJHub sticker picker for the pro_image_editor.
///
/// Shows 4 tabs: Business Frames, Logo, Photo Stickers, Shapes.
class AjhubEditorStickers extends StatefulWidget {
  final void Function(WidgetLayer widgetLayer) setLayer;
  final ScrollController scrollController;
  final String? businessLogoUrl;
  final String businessName;
  final String phoneNumber;
  final String emailAddress;
  final String address;
  final String website;

  const AjhubEditorStickers({
    super.key,
    required this.setLayer,
    required this.scrollController,
    this.businessLogoUrl,
    this.businessName = '',
    this.phoneNumber = '',
    this.emailAddress = '',
    this.address = '',
    this.website = '',
  });

  @override
  State<AjhubEditorStickers> createState() => _AjhubEditorStickersState();
}

enum LogoShapeType { none, circle, rounded }

class _AjhubEditorStickersState extends State<AjhubEditorStickers>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LogoShapeType _selectedLogoShape = LogoShapeType.none;
  Color _selectedShapeColor = Colors.white;

  static final _tabs = [
    const Tab(icon: Icon(Icons.business_center_outlined, size: 18), text: 'Frames'),
    const Tab(icon: Icon(Icons.badge_outlined, size: 18), text: 'Logo'),
    const Tab(icon: Icon(Icons.star_outline, size: 18), text: 'Stickers'),
    const Tab(icon: Icon(Icons.category_outlined, size: 18), text: 'Shapes'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Adds a full-size frame overlay (scale=1.0 so it covers the canvas).
  void _addFrameLayer(Widget child) {
    widget.setLayer(WidgetLayer(widget: child, scale: 1.0));
  }

  /// Adds a small sticker layer (scale=0.35, user can resize).
  void _addWidgetLayer(Widget child) {
    widget.setLayer(WidgetLayer(widget: child, scale: 0.35));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      color: Colors.grey.shade900,
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Tab Bar
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.redAccent,
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.grey.shade400,
            indicatorWeight: 2,
            labelStyle:
                const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            tabs: _tabs,
          ),
          const Divider(height: 1, color: Colors.grey),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFramesTab(),
                _buildLogoTab(),
                _buildPhotoStickersTab(),
                _buildShapesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // Frames Tab
  // ----------------------------------------------------------------
  Widget _buildFramesTab() {
    final frames = [
      'assets/frames/frm1.png',
      'assets/frames/frm2.png',
      'assets/frames/frm3.png',
      'assets/frames/frm4.png',
      'assets/frames/frm5.png',
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: frames.length,
      itemBuilder: (context, index) {
        final assetPath = frames[index];
        return GestureDetector(
          onTap: () {
            // Frames use scale 1.0 to fill the canvas like an overlay
            _addFrameLayer(
              SizedBox(
                width: 300,
                height: 300,
                child: Image.asset(assetPath, fit: BoxFit.fill),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade600, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white38,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoShapeOption(LogoShapeType type, IconData icon, String label) {
    final isSelected = _selectedLogoShape == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedLogoShape = type),
      child: Column(
        children: [
          Icon(icon, color: isSelected ? Colors.redAccent : Colors.grey.shade500),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isSelected ? Colors.redAccent : Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _applyLogoShape(Widget child) {
    switch (_selectedLogoShape) {
      case LogoShapeType.circle:
        return ClipOval(child: child);
      case LogoShapeType.rounded:
        return ClipRRect(borderRadius: BorderRadius.circular(16), child: child);
      default:
        return child;
    }
  }

  // ----------------------------------------------------------------
  // Logo Tab
  // ----------------------------------------------------------------
  Widget _buildLogoTab() {
    final logoUrl = widget.businessLogoUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLogoShapeOption(LogoShapeType.none, Icons.crop_square, 'Square'),
              _buildLogoShapeOption(LogoShapeType.circle, Icons.circle, 'Circle'),
              _buildLogoShapeOption(LogoShapeType.rounded, Icons.crop_square_rounded, 'Rounded'),
            ],
          ),
          const SizedBox(height: 20),
          // --- Pick from Phone Gallery ---
          GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final picked =
                  await picker.pickImage(source: ImageSource.gallery);
              if (picked != null) {
                final file = File(picked.path);
                _addWidgetLayer(
                  _applyLogoShape(
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.file(file, fit: BoxFit.cover),
                    ),
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent, width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined,
                      color: Colors.redAccent, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Pick from Gallery',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          if (logoUrl != null && logoUrl.isNotEmpty) ...
          [
            const SizedBox(height: 16),
            Text(
              'Or use your business logo:',
              style:
                  TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _addWidgetLayer(
                  _applyLogoShape(
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CachedNetworkImage(
                        imageUrl: logoUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.business, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.6),
                      width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: logoUrl,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.business, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.businessName,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ] else ...
          [
            const SizedBox(height: 20),
            Text(
              'No business logo set. Pick any image above.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // Photo Stickers Tab
  // ----------------------------------------------------------------
  Widget _buildPhotoStickersTab() {
    // Sticker emojis as text widgets — lightweight and always available.
    // Replace with Image.asset if PNG sticker assets are added to assets/icons/stickers/
    final stickers = [
      '🌟', '⭐', '🎉', '🎊', '🏆', '🥇',
      '❤️', '🔥', '✨', '💫', '🎯', '🎁',
      '🌈', '👑', '💎', '🎵', '📸', '🌸',
      '🎪', '💥', '🎀', '🍀', '🦋', '🌺',
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _addWidgetLayer(
              Text(
                stickers[index],
                style: const TextStyle(fontSize: 48),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(stickers[index], style: const TextStyle(fontSize: 28)),
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------------
  // Shapes Tab
  // ----------------------------------------------------------------
  Widget _buildShapesTab() {
    final shapes = <_ShapeItem>[
      _ShapeItem('Circle', Icons.circle_outlined, _ShapeType.circle),
      _ShapeItem('Rectangle', Icons.rectangle_outlined, _ShapeType.rectangle),
      _ShapeItem('Star', Icons.star_outline, _ShapeType.star),
      _ShapeItem('Arrow', Icons.arrow_forward, _ShapeType.arrow),
      _ShapeItem('Heart', Icons.favorite_outline, _ShapeType.heart),
      _ShapeItem('Triangle', Icons.change_history, _ShapeType.triangle),
    ];
    final colors = [Colors.white, Colors.black, Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple, Colors.yellow];

    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (ctx, i) {
              final color = colors[i];
              final isSelected = color == _selectedShapeColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedShapeColor = color),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: isSelected ? 3 : 1),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
            ),
            itemCount: shapes.length,
            itemBuilder: (context, index) {
        final shape = shapes[index];
        return GestureDetector(
          onTap: () {
            _addWidgetLayer(
              _ShapeWidget(type: shape.type, color: _selectedShapeColor),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade600, width: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(shape.icon, color: Colors.white, size: 32),
                const SizedBox(height: 4),
                Text(
                  shape.label,
                  style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    ),
    ),
    ],
    );
  }
}

// ----------------------------------------------------------------
// Supporting models and widgets
// ----------------------------------------------------------------

enum _ShapeType { circle, rectangle, star, arrow, heart, triangle }

class _ShapeItem {
  final String label;
  final IconData icon;
  final _ShapeType type;
  _ShapeItem(this.label, this.icon, this.type);
}

class _ShapeWidget extends StatelessWidget {
  final _ShapeType type;
  final Color color;
  const _ShapeWidget({required this.type, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: CustomPaint(
        painter: _ShapePainter(type: type, color: color),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final _ShapeType type;
  final Color color;
  _ShapePainter({required this.type, this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (type) {
      case _ShapeType.circle:
        canvas.drawCircle(Offset(cx, cy), size.width * 0.42, paint);
        break;
      case _ShapeType.rectangle:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
            const Radius.circular(8),
          ),
          paint,
        );
        break;
      case _ShapeType.star:
        paint.style = PaintingStyle.fill;
        paint.color = color;
        _drawStar(canvas, Offset(cx, cy), 5, size.width * 0.42,
            size.width * 0.18, paint);
        break;
      case _ShapeType.arrow:
        final path = Path()
          ..moveTo(8, cy)
          ..lineTo(size.width - 8, cy)
          ..moveTo(size.width - 24, cy - 16)
          ..lineTo(size.width - 8, cy)
          ..lineTo(size.width - 24, cy + 16);
        canvas.drawPath(path, paint);
        break;
      case _ShapeType.heart:
        _drawHeart(canvas, size, paint);
        break;
      case _ShapeType.triangle:
        final path = Path()
          ..moveTo(cx, 8)
          ..lineTo(size.width - 8, size.height - 8)
          ..lineTo(8, size.height - 8)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  void _drawStar(Canvas canvas, Offset center, int points, double outerRadius,
      double innerRadius, Paint paint) {
    final path = Path();
    final angle = (2 * 3.14159265358979) / points;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + r * _cos(-3.14159265358979 / 2 + i * angle / 2);
      final y = center.dy + r * _sin(-3.14159265358979 / 2 + i * angle / 2);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double angle) => angle == 0 ? 1.0 : _sinCos(angle, false);
  double _sin(double angle) => _sinCos(angle, true);
  double _sinCos(double angle, bool isSin) {
    // Simple approximation using series expansion
    final x = angle % (2 * 3.14159265358979);
    double result = isSin ? x : 1.0;
    double term = isSin ? x : 1.0;
    for (int i = 1; i < 10; i++) {
      term *= -(angle * angle) / ((2 * i) * (2 * i + (isSin ? 1 : -1)));
      result += term;
    }
    return result;
  }

  void _drawHeart(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w / 2, h * 0.85);
    path.cubicTo(0, h * 0.6, 0, h * 0.2, w / 4, h * 0.2);
    path.cubicTo(w * 0.4, h * 0.2, w / 2, h * 0.35, w / 2, h * 0.35);
    path.cubicTo(w / 2, h * 0.35, w * 0.6, h * 0.2, w * 0.75, h * 0.2);
    path.cubicTo(w, h * 0.2, w, h * 0.6, w / 2, h * 0.85);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

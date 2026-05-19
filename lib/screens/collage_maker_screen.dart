import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

enum _Layout {
  fourGrid,
  twoPort,
  twoLand,
  threeLeft,
  threeRight,
  threeLandTop,
  threeLandBot,
  fiveGrid,
  sixGrid,
  sixGridVertical,
  sixGridLargeTopLeft,
  fiveGridCenterTall,
  fourGridRightSplit,
  diamondFive,
  heartsSix,
  ovalsSix,
  diagonal,
}

enum _EditorTab { ratio, layout, margin, border, background }

class _LayoutMeta {
  final String label;
  final IconData icon;
  final int minImages;
  const _LayoutMeta(this.label, this.icon, this.minImages);
}

const _layoutMeta = {
  _Layout.twoPort:             _LayoutMeta('1×2',   Icons.view_column,      2),
  _Layout.twoLand:             _LayoutMeta('2×1',   Icons.view_stream,      2),
  _Layout.threeLeft:           _LayoutMeta('1+2',   Icons.view_sidebar,     3),
  _Layout.threeRight:          _LayoutMeta('2+1',   Icons.vertical_split,   3),
  _Layout.threeLandTop:        _LayoutMeta('═+2',   Icons.table_rows,       3),
  _Layout.threeLandBot:        _LayoutMeta('2+═',   Icons.table_rows_sharp, 3),
  _Layout.diagonal:            _LayoutMeta('╱╱╱',   Icons.linear_scale,     3),
  _Layout.fourGrid:            _LayoutMeta('2×2',   Icons.grid_view,        4),
  _Layout.fourGridRightSplit:  _LayoutMeta('1+3',   Icons.call_to_action,   4),
  _Layout.fiveGrid:            _LayoutMeta('1+4',   Icons.grid_on,          5),
  _Layout.fiveGridCenterTall:  _LayoutMeta('2+1+2', Icons.view_week,        5),
  _Layout.diamondFive:         _LayoutMeta('◇',     Icons.format_shapes,    5),
  _Layout.sixGrid:             _LayoutMeta('3×2',   Icons.apps,             6),
  _Layout.sixGridVertical:     _LayoutMeta('2×3',   Icons.grid_4x4,         6),
  _Layout.sixGridLargeTopLeft: _LayoutMeta('1+5',   Icons.dashboard,        6),
  _Layout.heartsSix:           _LayoutMeta('♡×6',   Icons.favorite,         6),
  _Layout.ovalsSix:            _LayoutMeta('◯×6',   Icons.lens,             6),
};

class CollageMakerScreen extends StatefulWidget {
  const CollageMakerScreen({super.key});

  @override
  State<CollageMakerScreen> createState() => _CollageMakerScreenState();
}

class _CollageMakerScreenState extends State<CollageMakerScreen> {
  List<File> _images = [];
  final Map<int, GlobalKey<_InteractiveSlotState>> _slotKeys = {};
  _Layout _layout = _Layout.fourGrid;
  final GlobalKey _repaintKey = GlobalKey();
  bool _isBusy = false;

  _EditorTab _currentTab = _EditorTab.layout;
  double _currentGap = 3.0;
  double _borderRadius = 0.0;
  Color _borderColor = Colors.white;
  double _ratio = 1.0;

  // ── Background state ────────────────────────────────────────────────────────
  Color _bgSolidColor = Colors.white;
  List<Color>? _bgGradientColors; // null = solid
  Alignment _bgGradientBegin = Alignment.topCenter;
  Alignment _bgGradientEnd = Alignment.bottomCenter;
  bool _bgIsGradient = false;

  // ── Text overlays ─────────────────────────────────────────────────────────────
  final List<_TextOverlay> _textOverlays = [];
  int _selectedTextIdx = -1; // -1 = none selected

  static const List<String> _fontOptions = [
    'Roboto', 'Poppins', 'Lato', 'Montserrat', 'Raleway',
    'Dancing Script', 'Pacifico', 'Great Vibes', 'Lobster',
    'Abril Fatface', 'Oswald', 'Playfair Display', 'Merriweather',
    'Shadows Into Light', 'Indie Flower', 'Righteous',
  ];

  static const List<_GradientPreset> _gradientPresets = [
    _GradientPreset('Sunset',   Color(0xFFFF6B6B), Color(0xFFFFE66D), Alignment.topLeft,   Alignment.bottomRight),
    _GradientPreset('Ocean',    Color(0xFF0575E6), Color(0xFF021B79), Alignment.topCenter, Alignment.bottomCenter),
    _GradientPreset('Purple',   Color(0xFF8E2DE2), Color(0xFF4A00E0), Alignment.topLeft,   Alignment.bottomRight),
    _GradientPreset('Peach',    Color(0xFFFFB347), Color(0xFFFFCC33), Alignment.topLeft,   Alignment.bottomRight),
    _GradientPreset('Forest',   Color(0xFF134E5E), Color(0xFF71B280), Alignment.topCenter, Alignment.bottomCenter),
    _GradientPreset('Rose',     Color(0xFFf953c6), Color(0xFFb91d73), Alignment.topLeft,   Alignment.bottomRight),
    _GradientPreset('Sky',      Color(0xFF56CCF2), Color(0xFF2F80ED), Alignment.topCenter, Alignment.bottomCenter),
    _GradientPreset('Midnight', Color(0xFF232526), Color(0xFF414345), Alignment.topCenter, Alignment.bottomCenter),
  ];

  _Layout _getDefaultLayoutForCount(int count) {
    if (count <= 2) return _Layout.twoPort;
    if (count == 3) return _Layout.threeLeft;
    if (count == 4) return _Layout.fourGrid;
    if (count == 5) return _Layout.fiveGrid;
    return _Layout.sixGrid;
  }

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85, limit: 6);
    if (picked.isNotEmpty) {
      if (picked.length < 2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least 2 photos for a collage.'), backgroundColor: Colors.orange),
          );
        }
        return;
      }
      setState(() {
        _images = picked.map((x) => File(x.path)).toList();
        _slotKeys.clear();
        _layout = _getDefaultLayoutForCount(_images.length);
      });
    }
  }

  Future<void> _reselectSingleImage(int index) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null && mounted) {
      setState(() {
        _images[index] = File(picked.path);
        // Reset the slot key so the InteractiveSlot reinitialises for the new image
        _slotKeys.remove(index);
      });
    }
  }

  GlobalKey<_InteractiveSlotState> _getSlotKey(int index) {
    return _slotKeys.putIfAbsent(index, () => GlobalKey<_InteractiveSlotState>());
  }

  Future<void> _export({bool share = false}) async {
    setState(() {
      _selectedTextIdx = -1; // Remove selection borders
      _isBusy = true;
    });
    // Allow the screen to rebuild without the overlay icons before taking screenshot
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final img = await boundary.toImage(pixelRatio: 3.0);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      final bytes = bd?.buffer.asUint8List();
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/collage_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(bytes);
      if (share) {
        await Share.shareXFiles([XFile(path)], text: 'Collage made with AJ Hub!');
      } else {
        await GallerySaver.saveImage(path, albumName: 'AJHUB Collage');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Collage saved to gallery!')),
          );
        }
      }
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canExport = _images.length >= 2;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Collage Maker',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        actions: _images.isNotEmpty
            ? [
                if (canExport)
                  IconButton(
                    onPressed: _showAddTextSheet,
                    icon: const Icon(Icons.text_fields_rounded),
                    tooltip: 'Add Text',
                  ),
                IconButton(onPressed: _pickImages, icon: const Icon(Icons.photo_library), tooltip: 'Reselect Photos'),
                if (canExport) ...[
                  IconButton(onPressed: _export, icon: const Icon(Icons.download), tooltip: 'Save'),
                  IconButton(onPressed: () => _export(share: true), icon: const Icon(Icons.share), tooltip: 'Share'),
                ]
              ]
            : [],
      ),
      body: _images.isEmpty ? _buildPicker() : _buildEditor(canExport),
    );
  }

  Widget _buildPicker() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grid_view_rounded, size: 80.sp, color: Colors.white38),
          SizedBox(height: 20.h),
          Text('Pick photos for your collage',
              style: TextStyle(color: Colors.white70, fontSize: 16.sp)),
          SizedBox(height: 6.h),
          Text('Select 2–6 photos', style: TextStyle(color: Colors.white38, fontSize: 13.sp)),
          SizedBox(height: 28.h),
          ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.photo_library),
            label: const Text('Select Photos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(bool canExport) {
    return Column(
      children: [
        // Collage Preview
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _ratio,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTextIdx = -1),
                        child: Container(
                          decoration: _canvasDecoration(),
                          child: LayoutBuilder(builder: (ctx, box) {
                            final cw = box.maxWidth;
                            final ch = box.maxHeight;
                            return Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(_currentGap),
                                  child: _buildCollage(),
                                ),
                                // Draggable text overlays
                                for (int ti = 0; ti < _textOverlays.length; ti++)
                                  _buildTextOverlayWidget(ti, cw, ch),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isBusy)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.redAccent),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        _buildEditorBottom(canExport),
      ],
    );
  }

  Widget _buildEditorBottom(bool canExport) {
    return SafeArea(
      top: false,
      child: Container(
        color: const Color(0xFF1C1F26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tab Content
            SizedBox(
              height: 120.h,
              child: _buildTabContent(),
            ),
            // Tab Selector Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabButton('Ratio', _EditorTab.ratio),
                  _buildTabButton('Layout', _EditorTab.layout),
                  _buildTabButton('Margin', _EditorTab.margin),
                  _buildTabButton('Border', _EditorTab.border),
                  _buildTabButton('BG', _EditorTab.background),
                  GestureDetector(
                    onTap: canExport ? _export : null,
                    child: Icon(Icons.check, color: canExport ? Colors.white : Colors.white30, size: 28.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, _EditorTab tab) {
    final isSelected = _currentTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = tab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 13.sp, fontWeight: FontWeight.w500)),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 4.h),
              height: 2.h,
              width: 20.w,
              color: Colors.redAccent,
            )
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case _EditorTab.ratio:
        return Center(
           child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                 children: [
                    _buildRatioOption('1:1', 1.0),
                    _buildRatioOption('4:5', 4/5),
                    _buildRatioOption('16:9', 16/9),
                    _buildRatioOption('9:16', 9/16),
                    _buildRatioOption('3:4', 3/4),
                 ]
              )
           )
        );
      case _EditorTab.layout:
        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          scrollDirection: Axis.horizontal,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
             crossAxisCount: 2,
             mainAxisSpacing: 8.w,
             crossAxisSpacing: 8.h,
             childAspectRatio: 1.0,
          ),
          itemCount: _layoutMeta.length,
          itemBuilder: (ctx, i) {
             final e = _layoutMeta.entries.elementAt(i);
             final sel = _layout == e.key;
             final enabled = _images.length == e.value.minImages;
             return GestureDetector(
               onTap: enabled ? () => setState(() => _layout = e.key) : () {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('This layout requires exactly ${e.value.minImages} photos.'),
                     duration: const Duration(seconds: 2),
                     backgroundColor: Colors.redAccent,
                   ),
                 );
               },
               child: Container(
                 decoration: BoxDecoration(
                   color: Colors.transparent,
                   border: Border.all(color: sel ? Colors.redAccent : Colors.white30, width: sel ? 2 : 1),
                 ),
                 child: Icon(e.value.icon, color: enabled ? Colors.white : Colors.white30),
               )
             );
          }
        );
      case _EditorTab.margin:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Padding(
               padding: EdgeInsets.symmetric(horizontal: 24.w),
               child: Row(
                 children: [
                   const Icon(Icons.margin, color: Colors.white),
                   Expanded(
                     child: Slider(
                       value: _currentGap,
                       min: 0,
                       max: 40,
                       activeColor: Colors.redAccent,
                       onChanged: (v) => setState(() => _currentGap = v),
                     )
                   ),
                   Text('${_currentGap.toInt()}', style: const TextStyle(color: Colors.white)),
                 ]
               )
             )
          ]
        );
      case _EditorTab.border:
        final colors = [
          Colors.white, Colors.black, Colors.grey, Colors.blueGrey,
          Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
          Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
          Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
          Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
          Colors.brown,
          const Color(0xFFF8BBD0), const Color(0xFFE1BEE7), const Color(0xFFD1C4E9),
          const Color(0xFFC5CAE9), const Color(0xFFB3E5FC), const Color(0xFFB2EBF2),
          const Color(0xFFB2DFDB), const Color(0xFFC8E6C9), const Color(0xFFF0F4C3),
          const Color(0xFFFFF9C4), const Color(0xFFFFE0B2), const Color(0xFFFFCCBC),
        ];
        return Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
              SizedBox(
                 height: 40.h,
                 child: ListView.builder(
                   scrollDirection: Axis.horizontal,
                   itemCount: colors.length,
                   padding: EdgeInsets.symmetric(horizontal: 16.w),
                   itemBuilder: (ctx, i) {
                      final c = colors[i];
                      return GestureDetector(
                        onTap: () => setState(() => _borderColor = c),
                        child: Container(
                          width: 40.w,
                          margin: EdgeInsets.only(right: 8.w),
                          decoration: BoxDecoration(
                            color: c,
                            borderRadius: BorderRadius.circular(8.r),
                            border: _borderColor == c ? Border.all(color: Colors.redAccent, width: 2) : Border.all(color: Colors.white24, width: 1),
                          )
                        )
                      );
                   }
                 )
              ),
              SizedBox(height: 16.h),
              Padding(
               padding: EdgeInsets.symmetric(horizontal: 24.w),
               child: Row(
                 children: [
                   const Icon(Icons.rounded_corner, color: Colors.white),
                   Expanded(
                     child: Slider(
                       value: _borderRadius,
                       min: 0,
                       max: 40,
                       activeColor: Colors.redAccent,
                       onChanged: (v) => setState(() => _borderRadius = v),
                     )
                   ),
                   Text('${_borderRadius.toInt()}', style: const TextStyle(color: Colors.white)),
                 ]
               )
              )
           ],
        );

      case _EditorTab.background:
        return _buildBackgroundTab();
    }
  }

  // ── Background tab ───────────────────────────────────────────────────────────
  Decoration _canvasDecoration() {
    if (_bgIsGradient && _bgGradientColors != null) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: _bgGradientBegin,
          end: _bgGradientEnd,
          colors: _bgGradientColors!,
        ),
      );
    }
    return BoxDecoration(color: _bgSolidColor);
  }

  Widget _buildBackgroundTab() {
    final solidColors = [
      Colors.white, Colors.black, const Color(0xFFF5F5F5), const Color(0xFFFFF8E1),
      const Color(0xFFE3F2FD), const Color(0xFFFCE4EC), const Color(0xFFE8F5E9),
      const Color(0xFFEDE7F6), const Color(0xFFFFF9C4), const Color(0xFFF3E5F5),
      Colors.grey[200]!, Colors.grey[400]!, Colors.blueGrey[100]!,
      const Color(0xFFFFCDD2), const Color(0xFFB3E5FC), const Color(0xFFDCEDC8),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Solid / Gradient toggle
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Row(
            children: [
              _bgToggleChip('Solid', !_bgIsGradient, () => setState(() => _bgIsGradient = false)),
              SizedBox(width: 8.w),
              _bgToggleChip('Gradient', _bgIsGradient, () => setState(() => _bgIsGradient = true)),
            ],
          ),
        ),
        Expanded(
          child: _bgIsGradient
              ? _buildGradientPicker()
              : _buildSolidPicker(solidColors),
        ),
      ],
    );
  }

  Widget _bgToggleChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: selected ? Colors.redAccent : Colors.white12,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(label, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSolidPicker(List<Color> colors) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: colors.length,
      itemBuilder: (ctx, i) {
        final c = colors[i];
        final sel = !_bgIsGradient && _bgSolidColor == c;
        return GestureDetector(
          onTap: () => setState(() {
            _bgSolidColor = c;
            _bgGradientColors = null;
          }),
          child: Container(
            width: 44.w,
            height: 44.w,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: sel ? Colors.redAccent : Colors.white24,
                width: sel ? 2.5 : 1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientPicker() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: _gradientPresets.length,
      itemBuilder: (ctx, i) {
        final p = _gradientPresets[i];
        final sel = _bgIsGradient &&
            _bgGradientColors != null &&
            _bgGradientColors![0] == p.start &&
            _bgGradientColors![1] == p.end;
        return GestureDetector(
          onTap: () => setState(() {
            _bgIsGradient = true;
            _bgGradientColors = [p.start, p.end];
            _bgGradientBegin = p.begin;
            _bgGradientEnd = p.endAlign;
          }),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                margin: EdgeInsets.only(right: 10.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: p.begin,
                    end: p.endAlign,
                    colors: [p.start, p.end],
                  ),
                  border: Border.all(
                    color: sel ? Colors.redAccent : Colors.white24,
                    width: sel ? 2.5 : 1,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(p.name, style: TextStyle(color: Colors.white54, fontSize: 9.sp)),
            ],
          ),
        );
      },
    );
  }

  // ── Per-image edit bottom-sheet ───────────────────────────────────────────────
  void _showImageEditSheet(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1F26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _editAction(Icons.swap_horiz, 'Replace', () {
                Navigator.pop(context);
                _reselectSingleImage(index);
              }),
              _editAction(Icons.delete_outline, 'Delete', () {
                Navigator.pop(context);
                _deleteImage(index);
              }, color: Colors.redAccent),
              _editAction(Icons.rotate_right, 'Rotate', () {
                Navigator.pop(context);
                _rotateSlot(index);
              }),
              _editAction(Icons.zoom_out_map, 'Reset', () {
                Navigator.pop(context);
                _slotKeys[index]?.currentState?.resetToFit();
              }),
              _editAction(Icons.crop, 'Crop', () {
                Navigator.pop(context);
                _cropImage(index);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editAction(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final c = color ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: c, size: 26.sp),
          ),
          SizedBox(height: 6.h),
          Text(label, style: TextStyle(color: c, fontSize: 11.sp)),
        ],
      ),
    );
  }

  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
      _slotKeys.remove(index);
      // Re-key remaining slots
      final newKeys = <int, GlobalKey<_InteractiveSlotState>>{};
      for (int i = 0; i < _images.length; i++) {
        if (_slotKeys.containsKey(i < index ? i : i + 1)) {
          newKeys[i] = _slotKeys[i < index ? i : i + 1]!;
        }
      }
      _slotKeys
        ..clear()
        ..addAll(newKeys);
      if (_images.length >= 2) {
        _layout = _getDefaultLayoutForCount(_images.length);
      }
    });
  }

  void _rotateSlot(int index) {
    _slotKeys[index]?.currentState?.rotate90();
  }

  void _cropImage(int index) async {
    final file = _images[index];
    final bytes = await file.readAsBytes();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProImageEditor.memory(
          bytes,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (imageBytes) async {
              final newFile = File(file.path)..writeAsBytesSync(imageBytes);
              setState(() {
                _images[index] = newFile;
              });
              Navigator.pop(context); // Close editor
            },
            onCloseEditor: (_) => Navigator.pop(context),
          ),
          configs: const ProImageEditorConfigs(
            designMode: ImageEditorDesignMode.material,
            mainEditor: MainEditorConfigs(
              tools: [SubEditorMode.cropRotate],
            ),
          ),
        ),
      ),
    );
  }


  // ── Text overlay methods ───────────────────────────────────────────────────────
  void _showAddTextSheet({int? editIndex}) {
    final textCtrl = TextEditingController();
    String selFont = _fontOptions[0];
    Color selColor = Colors.white;
    double selSize = 32;

    if (editIndex != null) {
      final existing = _textOverlays[editIndex];
      textCtrl.text = existing.text;
      selFont = existing.fontFamily;
      selColor = existing.color;
      selSize = existing.fontSize;
    }

    final palette = [
      Colors.white, Colors.black, Colors.yellow, Colors.red,
      Colors.blue, Colors.green, Colors.orange, Colors.pink,
      Colors.cyan, Colors.purple, Colors.teal, Colors.amber,
      const Color(0xFFFF6B6B), const Color(0xFF56CCF2), const Color(0xFFF953C6),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1F26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 16.h,
            left: 16.w, right: 16.w, top: 20.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40.w, height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // Text Input
                TextField(
                  controller: textCtrl,
                  autofocus: true,
                  style: GoogleFonts.getFont(
                    selFont, 
                    color: selColor, 
                    fontSize: 20.sp,
                    shadows: selColor == Colors.black ? null : [Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.5))],
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your text...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                // Font Picker
                Text('Font', style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
                SizedBox(height: 6.h),
                SizedBox(
                  height: 40.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _fontOptions.length,
                    itemBuilder: (_, fi) {
                      final f = _fontOptions[fi];
                      final sel = f == selFont;
                      return GestureDetector(
                        onTap: () => setSheet(() => selFont = f),
                        child: Container(
                          margin: EdgeInsets.only(right: 8.w),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: sel ? Colors.redAccent : Colors.white10,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(f,
                            style: GoogleFonts.getFont(f,
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 14.h),
                // Color Picker
                Text('Color', style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
                SizedBox(height: 6.h),
                SizedBox(
                  height: 36.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: palette.length,
                    itemBuilder: (_, ci) {
                      final c = palette[ci];
                      final sel = c == selColor;
                      return GestureDetector(
                        onTap: () => setSheet(() => selColor = c),
                        child: Container(
                          width: 36.w, height: 36.w,
                          margin: EdgeInsets.only(right: 8.w),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: sel ? Colors.redAccent : Colors.white24,
                              width: sel ? 2.5 : 1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 14.h),
                // Size Slider
                Row(
                  children: [
                    Text('Size', style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
                    Expanded(
                      child: Slider(
                        value: selSize,
                        min: 10,
                        max: 120,
                        activeColor: Colors.redAccent,
                        onChanged: (v) => setSheet(() => selSize = v),
                      ),
                    ),
                    Text('${selSize.toInt()}', style: const TextStyle(color: Colors.white)),
                  ],
                ),
                SizedBox(height: 14.h),
                // Add Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    onPressed: () {
                      final text = textCtrl.text.trim();
                      if (text.isEmpty) return;
                      Navigator.pop(sheetCtx);
                      setState(() {
                        if (editIndex != null) {
                          _textOverlays[editIndex] = _textOverlays[editIndex].copyWith(
                            text: text,
                            fontFamily: selFont,
                            color: selColor,
                            fontSize: selSize,
                          );
                        } else {
                          _textOverlays.add(_TextOverlay(
                            text: text,
                            fontFamily: selFont,
                            color: selColor,
                            fontSize: selSize,
                            dx: 0.5, dy: 0.5,
                          ));
                          _selectedTextIdx = _textOverlays.length - 1;
                        }
                      });
                    },
                    child: Text(editIndex != null ? 'Update Text' : 'Add to Collage', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextOverlayWidget(int ti, double cw, double ch) {
    final ov = _textOverlays[ti];
    final isSelected = _selectedTextIdx == ti;
    TextStyle style;
    try {
      style = GoogleFonts.getFont(
        ov.fontFamily,
        fontSize: ov.fontSize,
        color: ov.color,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.4)),
        ],
      );
    } catch (_) {
      style = TextStyle(
        fontSize: ov.fontSize,
        color: ov.color,
        fontWeight: FontWeight.bold,
      );
    }

    return Positioned(
      left: ov.dx * cw - 60 - 14, // shift further left by padding
      top: ov.dy * ch - ov.fontSize / 2 - 14, // shift further up by padding
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (isSelected) {
            _showAddTextSheet(editIndex: ti);
          } else {
            setState(() => _selectedTextIdx = ti);
          }
        },
        onPanUpdate: (d) => setState(() {
          _textOverlays[ti] = ov.copyWith(
            dx: ((ov.dx * cw + d.delta.dx) / cw).clamp(0.0, 1.0),
            dy: ((ov.dy * ch + d.delta.dy) / ch).clamp(0.0, 1.0),
          );
        }),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(14), // Gives stack enough bounds to capture touches
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: isSelected
                    ? BoxDecoration(
                        border: Border.all(color: Colors.redAccent.withOpacity(0.8), width: 1.5),
                        borderRadius: BorderRadius.circular(4.r),
                      )
                    : null,
                child: Text(ov.text, style: style),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() {
                    _textOverlays.removeAt(ti);
                    _selectedTextIdx = -1;
                  }),
                  child: Container(
                    width: 28, // touched up target size
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatioOption(String label, double ratioValue) {
    final isSelected = _ratio == ratioValue;
    return GestureDetector(
      onTap: () => setState(() => _ratio = ratioValue),
      child: Container(
         margin: EdgeInsets.symmetric(horizontal: 8.w),
         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
         decoration: BoxDecoration(
           color: isSelected ? Colors.redAccent : Colors.white12,
           borderRadius: BorderRadius.circular(8.r),
         ),
         child: Text(label, style: const TextStyle(color: Colors.white)),
      )
    );
  }

  Widget _buildCollage() {
    final gap = _currentGap;
    switch (_layout) {
      // ─── 2 images ───────────────────────────────────────────────────────────
      case _Layout.twoPort:
        return Row(children: [
          Expanded(child: _slot(0)),
          SizedBox(width: gap),
          Expanded(child: _slot(1)),
        ]);

      case _Layout.twoLand:
        return Column(children: [
          Expanded(child: _slot(0)),
          SizedBox(height: gap),
          Expanded(child: _slot(1)),
        ]);

      // ─── 3 images ───────────────────────────────────────────────────────────
      case _Layout.threeLeft:
        return Row(children: [
          Expanded(flex: 2, child: _slot(0)),
          SizedBox(width: gap),
          Expanded(
            child: Column(children: [
              Expanded(child: _slot(1)),
              SizedBox(height: gap),
              Expanded(child: _slot(2)),
            ]),
          ),
        ]);

      case _Layout.threeRight:
        return Row(children: [
          Expanded(
            child: Column(children: [
              Expanded(child: _slot(0)),
              SizedBox(height: gap),
              Expanded(child: _slot(1)),
            ]),
          ),
          SizedBox(width: gap),
          Expanded(flex: 2, child: _slot(2)),
        ]);

      // Full-width top + 2 below
      case _Layout.threeLandTop:
        return Column(children: [
          Expanded(flex: 2, child: _slot(0)),
          SizedBox(height: gap),
          Expanded(
            child: Row(children: [
              Expanded(child: _slot(1)),
              SizedBox(width: gap),
              Expanded(child: _slot(2)),
            ]),
          ),
        ]);

      // 2 above + full-width bottom
      case _Layout.threeLandBot:
        return Column(children: [
          Expanded(
            child: Row(children: [
              Expanded(child: _slot(0)),
              SizedBox(width: gap),
              Expanded(child: _slot(1)),
            ]),
          ),
          SizedBox(height: gap),
          Expanded(flex: 2, child: _slot(2)),
        ]);

      // ─── 4 images ───────────────────────────────────────────────────────────
      case _Layout.fourGrid:
        return Column(children: [
          Expanded(child: Row(children: [
            Expanded(child: _slot(0)),
            SizedBox(width: gap),
            Expanded(child: _slot(1)),
          ])),
          SizedBox(height: gap),
          Expanded(child: Row(children: [
            Expanded(child: _slot(2)),
            SizedBox(width: gap),
            Expanded(child: _slot(3)),
          ])),
        ]);

      // ─── NEW: 4 images complex ──────────────────────────────────────────────
      case _Layout.fourGridRightSplit:
        return Row(children: [
          Expanded(child: _slot(0)),
          SizedBox(width: gap),
          Expanded(
            child: Column(children: [
              Expanded(child: _slot(1)),
              SizedBox(height: gap),
              Expanded(
                child: Row(children: [
                  Expanded(child: _slot(2)),
                  SizedBox(width: gap),
                  Expanded(child: _slot(3)),
                ]),
              ),
            ]),
          ),
        ]);

      // ─── 5 images ───────────────────────────────────────────────────────────
      // Big image left, 4 small on right
      case _Layout.fiveGrid:
        return Row(children: [
          Expanded(flex: 2, child: _slot(0)),
          SizedBox(width: gap),
          Expanded(
            child: Column(children: [
              Expanded(child: Row(children: [
                Expanded(child: _slot(1)),
                SizedBox(width: gap),
                Expanded(child: _slot(2)),
              ])),
              SizedBox(height: gap),
              Expanded(child: Row(children: [
                Expanded(child: _slot(3)),
                SizedBox(width: gap),
                Expanded(child: _slot(4)),
              ])),
            ]),
          ),
        ]);

      case _Layout.fiveGridCenterTall:
        return Row(children: [
          Expanded(child: Column(children: [ Expanded(child: _slot(0)), SizedBox(height: gap), Expanded(child: _slot(1)) ])),
          SizedBox(width: gap),
          Expanded(child: _slot(2)),
          SizedBox(width: gap),
          Expanded(child: Column(children: [ Expanded(child: _slot(3)), SizedBox(height: gap), Expanded(child: _slot(4)) ])),
        ]);

      // ─── 6 images ───────────────────────────────────────────────────────────
      case _Layout.sixGrid:
        return Column(children: [
          Expanded(child: Row(children: [
            Expanded(child: _slot(0)),
            SizedBox(width: gap),
            Expanded(child: _slot(1)),
            SizedBox(width: gap),
            Expanded(child: _slot(2)),
          ])),
          SizedBox(height: gap),
          Expanded(child: Row(children: [
            Expanded(child: _slot(3)),
            SizedBox(width: gap),
            Expanded(child: _slot(4)),
            SizedBox(width: gap),
            Expanded(child: _slot(5)),
          ])),
        ]);

      case _Layout.sixGridVertical:
        return Column(children: [
          Expanded(child: Row(children: [ Expanded(child: _slot(0)), SizedBox(width:gap), Expanded(child: _slot(1)) ])),
          SizedBox(height: gap),
          Expanded(child: Row(children: [ Expanded(child: _slot(2)), SizedBox(width:gap), Expanded(child: _slot(3)) ])),
          SizedBox(height: gap),
          Expanded(child: Row(children: [ Expanded(child: _slot(4)), SizedBox(width:gap), Expanded(child: _slot(5)) ])),
        ]);

      case _Layout.sixGridLargeTopLeft:
        return Column(children: [
          Expanded(
            flex: 2,
            child: Row(children: [
              Expanded(flex: 2, child: _slot(0)),
              SizedBox(width: gap),
              Expanded(
                flex: 1,
                child: Column(children: [
                  Expanded(child: _slot(1)),
                  SizedBox(height: gap),
                  Expanded(child: _slot(2)),
                ]),
              ),
            ]),
          ),
          SizedBox(height: gap),
          Expanded(
            flex: 1,
            child: Row(children: [
              Expanded(child: _slot(3)),
              SizedBox(width: gap),
              Expanded(child: _slot(4)),
              SizedBox(width: gap),
              Expanded(child: _slot(5)),
            ]),
          ),
        ]);

      case _Layout.heartsSix:
        return Column(children: [
          Expanded(child: Row(children: [ Expanded(child: ClipPath(clipper: _HeartClipper(), child: _slotFill(0))), SizedBox(width:gap), Expanded(child: ClipPath(clipper: _HeartClipper(), child: _slotFill(1))) ])),
          SizedBox(height: gap),
          Expanded(child: Row(children: [ Expanded(child: ClipPath(clipper: _HeartClipper(), child: _slotFill(2))), SizedBox(width:gap), Expanded(child: ClipPath(clipper: _HeartClipper(), child: _slotFill(3))) ])),
          SizedBox(height: gap),
          Expanded(child: Row(children: [ Expanded(child: ClipPath(clipper: _HeartClipper(), child: _slotFill(4))), SizedBox(width:gap), Expanded(child: ClipPath(clipper: _HeartClipper(), child: _slotFill(5))) ])),
        ]);

      case _Layout.ovalsSix:
        return Column(children: [
          Expanded(child: Row(children: [ Expanded(child: ClipOval(child: _slotFill(0))), SizedBox(width:gap), Expanded(child: ClipOval(child: _slotFill(1))) ])),
          SizedBox(height: gap),
          Expanded(child: Row(children: [ Expanded(child: ClipOval(child: _slotFill(2))), SizedBox(width:gap), Expanded(child: ClipOval(child: _slotFill(3))) ])),
          SizedBox(height: gap),
          Expanded(child: Row(children: [ Expanded(child: ClipOval(child: _slotFill(4))), SizedBox(width:gap), Expanded(child: ClipOval(child: _slotFill(5))) ])),
        ]);

      case _Layout.diamondFive:
        return LayoutBuilder(builder: (ctx, constraints) {
          return Stack(
            children: [
              Positioned.fill(child: ClipPath(clipper: const _DiamondClipper(0), child: _slotFill(0))),
              Positioned.fill(child: ClipPath(clipper: const _DiamondClipper(1), child: _slotFill(1))),
              Positioned.fill(child: ClipPath(clipper: const _DiamondClipper(2), child: _slotFill(2))),
              Positioned.fill(child: ClipPath(clipper: const _DiamondClipper(3), child: _slotFill(3))),
              Positioned.fill(child: ClipPath(clipper: const _DiamondClipper(4), child: _slotFill(4))),
            ],
          );
        });

      // ─── Diagonal strips (3 images) ──────────────────────────────────────────
      case _Layout.diagonal:
        return LayoutBuilder(builder: (ctx, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          const slant = 0.18; // fraction of width for the diagonal shift
          return ClipRect(
            child: Stack(
              children: [
                // Left strip
                ClipPath(
                  clipper: _DiagonalClipper(position: 0, total: 3, slant: slant, w: w, h: h),
                  child: SizedBox(width: w, height: h, child: _slotFill(0)),
                ),
                // Middle strip
                ClipPath(
                  clipper: _DiagonalClipper(position: 1, total: 3, slant: slant, w: w, h: h),
                  child: SizedBox(width: w, height: h, child: _slotFill(1)),
                ),
                // Right strip
                ClipPath(
                  clipper: _DiagonalClipper(position: 2, total: 3, slant: slant, w: w, h: h),
                  child: SizedBox(width: w, height: h, child: _slotFill(2)),
                ),
              ],
            ),
          );
        });
    }
  }

  Widget _wrapSlot(Widget child) {
    if (_layout == _Layout.diagonal) {
      return child;
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: _borderColor, width: 2.5),
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_borderRadius > 0 ? _borderRadius - 1 : 0),
        child: child,
      ),
    );
  }

  Widget _slot(int i) {
    Widget slotWidget;
    if (i < _images.length) {
      slotWidget = GestureDetector(
        onTap: _isBusy ? null : () => _showImageEditSheet(i),
        child: _InteractiveSlot(
          key: _getSlotKey(i),
          file: _images[i],
        ),
      );
    } else {
      slotWidget = GestureDetector(
        onTap: _pickImages,
        child: Container(
          color: Colors.grey[850],
          child: Center(
            child: Icon(Icons.add_photo_alternate_outlined,
                color: Colors.white24, size: 40.sp),
          ),
        ),
      );
    }
    return _wrapSlot(slotWidget);
  }

  Widget _slotFill(int i) {
    if (i < _images.length) {
      return GestureDetector(
        onTap: _isBusy ? null : () => _showImageEditSheet(i),
        child: _InteractiveSlot(
          key: _getSlotKey(i),
          file: _images[i],
        ),
      );
    }
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        color: Colors.grey[850],
        child: Center(
          child: Icon(Icons.add_photo_alternate_outlined,
              color: Colors.white24, size: 40.sp),
        ),
      ),
    );
  }


}

/// Clips a vertical diagonal strip for the diagonal collage layout.
class _DiagonalClipper extends CustomClipper<Path> {
  final int position;
  final int total;
  final double slant;
  final double w;
  final double h;

  const _DiagonalClipper({
    required this.position,
    required this.total,
    required this.slant,
    required this.w,
    required this.h,
  });

  @override
  Path getClip(Size size) {
    final stripW = w / total;
    final sl = w * slant;

    final left = position * stripW;
    final right = left + stripW;

    return Path()
      ..moveTo(left - sl, 0)
      ..lineTo(right - sl, 0)
      ..lineTo(right + sl, size.height)
      ..lineTo(left + sl, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant _DiagonalClipper old) =>
      old.position != position || old.slant != slant;
}

class _InteractiveSlot extends StatefulWidget {
  final File file;
  const _InteractiveSlot({super.key, required this.file});

  @override
  State<_InteractiveSlot> createState() => _InteractiveSlotState();
}

class _InteractiveSlotState extends State<_InteractiveSlot> {
  ui.Image? _imageInfo;
  TransformationController? _controller;
  Size? _lastViewSize;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant _InteractiveSlot old) {
    super.didUpdateWidget(old);
    if (old.file.path != widget.file.path) {
      _controller?.dispose();
      _controller = null;
      _imageInfo = null;
      _lastViewSize = null;
      _loadImage();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Exposed to parent via GlobalKey
  void resetToFit() {
    if (_imageInfo == null || _lastViewSize == null) return;
    final imgW = _imageInfo!.width.toDouble();
    final imgH = _imageInfo!.height.toDouble();
    final viewSize = _lastViewSize!;
    final scaleX = viewSize.width / imgW;
    final scaleY = viewSize.height / imgH;
    final coverScale = math.max(scaleX, scaleY);
    final initialX = (viewSize.width - (imgW * coverScale)) / 2;
    final initialY = (viewSize.height - (imgH * coverScale)) / 2;
    setState(() {
      _controller!.value = Matrix4.identity()
        ..translate(initialX, initialY)
        ..scale(coverScale);
    });
  }

  void rotate90() {
    if (_controller == null || _lastViewSize == null) return;
    final vs = _lastViewSize!;
    final cx = vs.width / 2;
    final cy = vs.height / 2;
    final current = _controller!.value.clone();
    final rotation = Matrix4.identity()
      ..translate(cx, cy)
      ..rotateZ(math.pi / 2)
      ..translate(-cx, -cy);
    setState(() {
      _controller!.value = rotation * current;
    });
  }

  Future<void> _loadImage() async {
    try {
      if (await widget.file.exists()) {
        final data = await widget.file.readAsBytes();
        final img = await decodeImageFromList(data);
        if (mounted) setState(() => _imageInfo = img);
      } else {
        if (kDebugMode) {
          print('File not found: ${widget.file.path}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading image for collage: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageInfo == null) {
      return Container(color: Colors.grey[900]);
    }

    return LayoutBuilder(builder: (ctx, constraints) {
      final viewSize = Size(constraints.maxWidth, constraints.maxHeight);

      // Initialize or re-center if container layout size changes significantly
      if (_controller == null || _lastViewSize != viewSize) {
        _lastViewSize = viewSize;
        final imgW = _imageInfo!.width.toDouble();
        final imgH = _imageInfo!.height.toDouble();

        final scaleX = viewSize.width / imgW;
        final scaleY = viewSize.height / imgH;
        final coverScale = math.max(scaleX, scaleY);

        final initialX = (viewSize.width - (imgW * coverScale)) / 2;
        final initialY = (viewSize.height - (imgH * coverScale)) / 2;

        _controller ??= TransformationController();
        _controller!.value = Matrix4.identity()
          ..translate(initialX, initialY)
          ..scale(coverScale);
      }

      return ClipRect(
        child: Stack(
          children: [
            Container(
              color: Colors.grey[900],
              child: InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                minScale: 0.05,
                maxScale: 10.0,
                transformationController: _controller,
                child: Image.file(
                  widget.file,
                  fit: BoxFit.none,
                  alignment: Alignment.topLeft,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _HeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;
    Path path = Path();
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.2 * width, height * 0.1, -0.25 * width, height * 0.6, 0.5 * width, height * 0.95);
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.8 * width, height * 0.1, 1.25 * width, height * 0.6, 0.5 * width, height * 0.95);
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _DiamondClipper extends CustomClipper<Path> {
  final int position;
  const _DiamondClipper(this.position);
  
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    final double g = 4.0; // small internal gap
    switch (position) {
      case 0: // Center
        path.moveTo(w/2, g);
        path.lineTo(w - g, h/2);
        path.lineTo(w/2, h - g);
        path.lineTo(g, h/2);
        path.close();
        break;
      case 1: // TL
        path.moveTo(0, 0);
        path.lineTo(w/2 - g, 0);
        path.lineTo(0, h/2 - g);
        path.close();
        break;
      case 2: // TR
        path.moveTo(w/2 + g, 0);
        path.lineTo(w, 0);
        path.lineTo(w, h/2 - g);
        path.close();
        break;
      case 3: // BR
        path.moveTo(w, h/2 + g);
        path.lineTo(w, h);
        path.lineTo(w/2 + g, h);
        path.close();
        break;
      case 4: // BL
        path.moveTo(0, h/2 + g);
        path.lineTo(w/2 - g, h);
        path.lineTo(0, h);
        path.close();
        break;
    }
    return path;
  }
  @override
  bool shouldReclip(_DiamondClipper old) => old.position != position;
}

// ─── Text overlay data model ──────────────────────────────────────────────────
class _TextOverlay {
  final String text;
  final String fontFamily;
  final Color color;
  final double fontSize;
  final double dx; // fractional x (0.0–1.0) of canvas width
  final double dy; // fractional y (0.0–1.0) of canvas height

  const _TextOverlay({
    required this.text,
    required this.fontFamily,
    required this.color,
    required this.fontSize,
    required this.dx,
    required this.dy,
  });

  _TextOverlay copyWith({String? text, String? fontFamily, Color? color, double? fontSize, double? dx, double? dy}) {
    return _TextOverlay(
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
    );
  }
}

class _GradientPreset {
  final String name;
  final Color start;
  final Color end;
  final Alignment begin;
  final Alignment endAlign;

  const _GradientPreset(
    this.name,
    this.start,
    this.end,
    this.begin,
    this.endAlign,
  );
}

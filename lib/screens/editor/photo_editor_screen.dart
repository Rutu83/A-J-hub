import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:image_picker/image_picker.dart';

import 'package:ajhub_app/model/custom_template_model.dart';
import 'package:ajhub_app/screens/editor/editor_stickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:ajhub_app/utils/configs.dart';
import 'package:ajhub_app/screens/ai/ai_image_generator_screen.dart';

/// Full-featured AJHub image editor, powered by `pro_image_editor`.
class PhotoEditorScreen extends StatefulWidget {
  final String? imageUrl;
  final String? businessLogoUrl;
  final File? localFile; // for gallery/camera picks
  /// Optional: when provided, text layers from the template are auto-injected.
  final CustomTemplate? customTemplate;

  const PhotoEditorScreen({
    super.key,
    this.imageUrl,
    this.businessLogoUrl,
    this.customTemplate,
    this.localFile,
  });

  // Convenience constructor for local files
  factory PhotoEditorScreen.fromFile(File file) =>
      PhotoEditorScreen(localFile: file);

  @override
  State<PhotoEditorScreen> createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends State<PhotoEditorScreen> {
  String? _businessLogoUrl;
  String _businessName = '';
  String _phoneNumber = '';
  String _emailAddress = '';
  String _address = '';
  String _website = '';
  bool _loading = true;
  File? _currentLocalFile; // tracks live-replaced background image
  // Notifiers for image layers — survive ProImageEditor widget rebuilds
  final List<ValueNotifier<File?>> _imageLayerNotifiers = [];

  GlobalKey<ProImageEditorState> _editorKey = GlobalKey<ProImageEditorState>();

  @override
  void initState() {
    super.initState();
    _currentLocalFile = widget.localFile;
    _loadBusinessData();
  }

  @override
  void dispose() {
    for (final n in _imageLayerNotifiers) n.dispose();
    super.dispose();
  }

  Future<void> _loadBusinessData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('active_business');
      if (raw != null) {
        final data = json.decode(raw) as Map<String, dynamic>;
        setState(() {
          _businessLogoUrl = data['logo'] as String?;
          _businessName = data['business_name'] ?? '';
          _phoneNumber = data['mobile_number'] ?? '';
          _emailAddress = data['email'] ?? '';
          _address = data['address'] ?? '';
          _website = data['website'] ?? '';
        });
      }
    } catch (_) {
      // Fail silently — editor opens without business data
    } finally {
      if (mounted) setState(() => _loading = false);
      // Layers are injected via onImageDecoded callback
    }
  }

  /// Injects template text layers using rigorous algebraic Box.contain math
  /// to map admin canvas coordinates to Flutter screen pixels.
  ///
  /// The user's `decodedImageSize` hypothesis was incorrect because 
  /// `editorState.sizesManager.decodedImageSize` returns raw image pixels (1.0 scale),
  /// NOT the rendered screen limits, causing coordinates to massively overflow mobile screens.
  void _injectTemplateLayers(ProImageEditorState editorState) {
    if (!mounted) return;
    final template = widget.customTemplate;
    if (template == null || template.layers.isEmpty) return;

    final canvasW = template.canvasWidth.toDouble();
    final canvasH = template.canvasHeight.toDouble();

    final body = editorState.sizesManager.bodySize;
    // Guard: ensure layout is ready so scale isn't broken
    if (body.width <= 0 || body.height <= 0) return;

    // ALGEBRAIC PROOF: 
    // The background image is drawn inside `body` via BoxFit.contain.
    // The image size on screen is therefore canvas * scale.
    final double scale = math.min(body.width / canvasW, body.height / canvasH);

    debugPrint(
      '[LayerInject] canvas=${canvasW}x$canvasH '
      'body=${body.width}x${body.height} computed_scale=$scale',
    );

    for (final layer in template.layers) {
      if (layer.layerType != 'text' && layer.layerType != 'image') continue;

      // Because BoxFit.contain centers the image in `body`, the image center
      // aligns strictly with the body center. The translation from center is:
      final offsetX = (layer.posX - canvasW / 2) * scale;
      final offsetY = (layer.posY - canvasH / 2) * scale;

      debugPrint(
        '[LayerInject] "${layer.layerName}" type=${layer.layerType} '
        'posX=${layer.posX} posY=${layer.posY} '
        '→ offsetX=$offsetX offsetY=$offsetY',
      );

      if (layer.layerType == 'image' &&
          layer.imageUrl != null &&
          layer.imageUrl!.isNotEmpty) {
        // Create a persistent notifier so state survives ProImageEditor widget rebuilds
        final notifier = ValueNotifier<File?>(null);
        _imageLayerNotifiers.add(notifier);

        final imgW = (layer.width ?? 200) * scale;
        final imgH = (layer.height ?? 200) * scale;
        editorState.addLayer(
          WidgetLayer(
            offset: Offset(offsetX, offsetY),
            widget: SizedBox(
              width: imgW,
              height: imgH,
              child: _ReplaceableImageLayer(
                initialImageUrl: layer.imageUrl!,
                width: imgW,
                height: imgH,
                localFileNotifier: notifier,
              ),
            ),
          ),
        );
        continue;
      }

      // Font scale: admin font size in canvas px → screen px, then ÷ 24
      // (pro_image_editor default internal text render size is 24px)
      final fontScale = (layer.fontSize ?? 50.0) * scale / 24.0;

      TextStyle? style;
      if (layer.fontFamily != null && layer.fontFamily!.isNotEmpty) {
        try {
          style = GoogleFonts.getFont(layer.fontFamily!);
        } catch (_) {
          style = TextStyle(fontFamily: layer.fontFamily);
        }
      }

      editorState.addLayer(
        TextLayer(
          text: (layer.defaultValue?.isNotEmpty == true)
              ? layer.defaultValue!
              : (layer.layerName.isNotEmpty ? layer.layerName : 'Edit text'),
          color: _hexToColor(layer.colorHex),
          background: Colors.transparent,
          colorMode: LayerBackgroundMode.onlyColor,
          offset: Offset(offsetX, offsetY),
          fontScale: fontScale,
          textStyle: style,
          align: layer.textAlign == 'left'
              ? TextAlign.left
              : (layer.textAlign == 'right'
                    ? TextAlign.right
                    : TextAlign.center),
        ),
      );
    }
  }

  Color _hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.white;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      );
    }

    final hasUrl = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;
    final hasFile = _currentLocalFile != null;
    if (!hasUrl && !hasFile) {
      return _buildPlaceholder(context);
    }

    // Shared editor callbacks
    final callbacks = ProImageEditorCallbacks(
      onImageEditingComplete: (Uint8List bytes) async {
        _handleExport(bytes);
      },
      mainEditorCallbacks: MainEditorCallbacks(
        onImageDecoded: () {
          if (widget.customTemplate != null &&
              widget.customTemplate!.layers.isNotEmpty) {
            // Defer to the next frame so bodySize is fully laid out before
            // we compute BoxFit.contain dimensions to properly scale positions.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final editorState = _editorKey.currentState;
              if (editorState != null && mounted) {
                _injectTemplateLayers(editorState);
              }
            });
          }
        },
      ),
    );

    final List<TextStyle> customFonts = [];
    if (widget.customTemplate != null) {
      for (final layer in widget.customTemplate!.layers) {
        if (layer.layerType == 'text' &&
            layer.fontFamily != null &&
            layer.fontFamily!.isNotEmpty) {
          try {
            final style = GoogleFonts.getFont(layer.fontFamily!);
            if (!customFonts.any((e) => e.fontFamily == style.fontFamily)) {
              customFonts.add(style);
            }
          } catch (_) {
            final style = TextStyle(fontFamily: layer.fontFamily);
            if (!customFonts.any((e) => e.fontFamily == style.fontFamily)) {
              customFonts.add(style);
            }
          }
        }
      }
    }

    final defaultFonts = [
      GoogleFonts.roboto(),
      GoogleFonts.lato(),
      GoogleFonts.openSans(),
      GoogleFonts.oswald(),
      GoogleFonts.pacifico(),
      GoogleFonts.caveat(),
    ];
    for (var f in defaultFonts) {
      if (!customFonts.any((e) => e.fontFamily == f.fontFamily)) {
        customFonts.add(f);
      }
    }

    // Shared editor configs
    final configs = ProImageEditorConfigs(
      designMode: ImageEditorDesignMode.material,
      textEditor: TextEditorConfigs(
        initialBackgroundColorMode: LayerBackgroundMode.onlyColor,
        showSelectFontStyleBottomBar: true,
        customTextStyles: customFonts,
      ),
      // === AJHub theme ===
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFD32F2F),
          secondary: const Color(0xFFD32F2F),
          surface: const Color(0xFF1A1A1A),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          selectedItemColor: Color(0xFFD32F2F),
          unselectedItemColor: Colors.grey,
        ),
      ),
      i18n: const I18n(
        stickerEditor: I18nStickerEditor(bottomNavigationBarText: 'Frames'),
        emojiEditor: I18nEmojiEditor(bottomNavigationBarText: 'Sticker'),
      ),
      mainEditor: MainEditorConfigs(
        enableZoom: true,
        tools: const [
          SubEditorMode.text,
          SubEditorMode.sticker,
          SubEditorMode.emoji,
          SubEditorMode.paint,
          SubEditorMode.filter,
          SubEditorMode.tune,
          SubEditorMode.blur,
          SubEditorMode.cropRotate,
        ],
      ),
      emojiEditor: const EmojiEditorConfigs(checkPlatformCompatibility: false),
      stickerEditor: StickerEditorConfigs(
        builder:
            (
              Function(WidgetLayer widgetLayer) setLayer,
              ScrollController scrollController,
            ) {
              return AjhubEditorStickers(
                setLayer: setLayer,
                scrollController: scrollController,
                businessLogoUrl: _businessLogoUrl,
                businessName: _businessName,
                phoneNumber: _phoneNumber,
                emailAddress: _emailAddress,
                address: _address,
                website: _website,
              );
            },
      ),
    );

    // Stack: ProImageEditor takes full screen, buttons float above toolbar
    return Stack(
      children: [
        if (_currentLocalFile != null)
          ProImageEditor.file(
            _currentLocalFile!,
            key: _editorKey,
            callbacks: callbacks,
            configs: configs,
          )
        else
          ProImageEditor.network(
            widget.imageUrl!,
            key: _editorKey,
            callbacks: callbacks,
            configs: configs,
          ),

        // ── Floating Action Buttons (AI Generation & Smart Scan) ──
        Positioned(
          bottom: 100,
          right: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // AI Generate Button
              GestureDetector(
                onTap: () async {
                  if (!AI_IMAGE_ENABLED) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AiImageGeneratorScreen(isHelperMode: true),
                      ),
                    );
                    return;
                  }

                  final dynamic result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AiImageGeneratorScreen(isHelperMode: true),
                    ),
                  );

                  if (result != null && result is File && mounted) {
                    final editorState = _editorKey.currentState;
                    if (editorState != null) {
                      editorState.addLayer(
                        WidgetLayer(
                          widget: Image.file(
                            result,
                            fit: BoxFit.contain,
                            width: 250,
                            height: 250,
                          ),
                          offset: Offset.zero,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C3CFF), Color(0xFFAB47BC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C3CFF).withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                      SizedBox(width: 5),
                      Text(
                        'AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Change Photo Button (bottom-left) ──
        Positioned(
          bottom: 100,
          left: 12,
          child: GestureDetector(
            onTap: _showChangePhotoSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: DefaultTextStyle.merge(
                style: const TextStyle(decoration: TextDecoration.none),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_camera_back_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Change Photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
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

  /// Shows a bottom sheet to replace the background photo.
  void _showChangePhotoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text(
                'Change Background Photo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pick a new photo to replace the current background',
                style: TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ChangePhotoOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD32F2F), Color(0xFFFF6659)],
                      ),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 92,
                        );
                        if (picked != null && mounted) {
                          setState(() {
                            _currentLocalFile = File(picked.path);
                            _editorKey =
                                GlobalKey<
                                  ProImageEditorState
                                >(); // force reload
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ChangePhotoOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      ),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                          imageQuality: 92,
                        );
                        if (picked != null && mounted) {
                          setState(() {
                            _currentLocalFile = File(picked.path);
                            _editorKey =
                                GlobalKey<
                                  ProImageEditorState
                                >(); // force reload
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Edit'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_search, size: 80, color: Colors.grey.shade600),
              const SizedBox(height: 16),
              Text(
                'Tap any image on the Home Screen\nand choose "Edit with Custom" to start.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// FIX: Export without await so the editor can close itself first.
  /// Then show the save/share sheet from the root navigator context.
  void _handleExport(Uint8List bytes) {
    // Schedule after current frame so editor pop doesn't conflict
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final dir = await getTemporaryDirectory();
        final filePath =
            '${dir.path}/ajhub_edit_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await File(filePath).writeAsBytes(bytes);

        if (!mounted) return;

        await showDialog(
          context: context,
          barrierColor: Colors.black87,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              '💾 Save Your Creation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: Row(
              children: [
                Expanded(
                  child: _ExportButton(
                    icon: Icons.save_alt_rounded,
                    label: 'Gallery',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD32F2F), Color(0xFFFF6659)],
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await GallerySaver.saveImage(
                        filePath,
                        albumName: 'AJHub',
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Saved to AJHub Gallery!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExportButton(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await SharePlus.instance.share(
                        ShareParams(
                          files: [XFile(filePath)],
                          text: 'Created with AJ Hub App! 🚀',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ChangePhotoOption({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _ReplaceableImageLayer ────────────────────────────────────────────────
/// A widget that shows a backend image layer and lets the user replace it.
/// State (the replacement File) lives in [localFileNotifier] at the
/// _PhotoEditorScreenState level so it survives ProImageEditor rebuilds.
class _ReplaceableImageLayer extends StatelessWidget {
  final String initialImageUrl;
  final double width;
  final double height;
  final ValueNotifier<File?> localFileNotifier;

  const _ReplaceableImageLayer({
    required this.initialImageUrl,
    required this.width,
    required this.height,
    required this.localFileNotifier,
  });

  void _showReplaceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text(
                'Replace Image Layer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pick a new photo for this template image.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ChangePhotoOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD32F2F), Color(0xFFFF6659)],
                      ),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 92,
                        );
                        if (picked != null) {
                          localFileNotifier.value = File(picked.path);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ChangePhotoOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      ),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                          imageQuality: 92,
                        );
                        if (picked != null) {
                          localFileNotifier.value = File(picked.path);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Single tap to show the replace sheet
      onTap: () => _showReplaceSheet(context),
      child: ValueListenableBuilder<File?>(
        valueListenable: localFileNotifier,
        builder: (_, localFile, __) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: localFile != null
                ? Image.file(localFile, fit: BoxFit.cover)
                : Image.network(
                    initialImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        Container(color: Colors.grey.shade800),
                  ),
          );
        },
      ),
    );
  }
}

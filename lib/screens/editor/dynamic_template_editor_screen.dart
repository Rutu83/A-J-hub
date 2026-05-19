import 'dart:io';
import 'dart:ui' as ui;

import 'package:ajhub_app/model/custom_template_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class DynamicTemplateEditorScreen extends StatefulWidget {
  final CustomTemplate template;

  const DynamicTemplateEditorScreen({
    super.key,
    required this.template,
  });

  @override
  State<DynamicTemplateEditorScreen> createState() =>
      _DynamicTemplateEditorScreenState();
}

class _LayerData {
  CustomTemplateLayer layer;
  double x;
  double y;
  String text;
  String? colorHex;
  double scale = 1.0;

  _LayerData({
    required this.layer,
    required this.x,
    required this.y,
    required this.text,
    this.colorHex,
  });
}

class _DynamicTemplateEditorScreenState
    extends State<DynamicTemplateEditorScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  List<_LayerData> _activeLayers = [];
  bool _isExporting = false;
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();
    _initLayers();
  }

  void _initLayers() {
    _activeLayers = widget.template.layers.map((layer) {
      return _LayerData(
        layer: layer,
        x: layer.posX,
        y: layer.posY,
        text: layer.layerType == 'text'
            ? (layer.layerName.isNotEmpty
                ? layer.layerName
                : 'Double tap to edit')
            : '',
        colorHex: layer.colorHex,
      );
    }).toList();
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

  TextAlign _getTextAlign(String? align) {
    if (align == 'left') return TextAlign.left;
    if (align == 'right') return TextAlign.right;
    return TextAlign.center;
  }

  Future<void> _exportImage() async {
    setState(() => _isExporting = true);
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Unable to capture frame.');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null) {
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/custom_edit_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);

        await GallerySaver.saveImage(filePath, albumName: 'AJHub');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Image Saved Successfully!'),
                backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error exporting: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _editLayerText(_LayerData layerData) {
    TextEditingController controller =
        TextEditingController(text: layerData.text);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.w,
            right: 16.w,
            top: 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Text',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    layerData.text = controller.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.template.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          _isExporting
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _exportImage,
                ),
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: widget.template.canvasHeight > 0
              ? widget.template.canvasWidth / widget.template.canvasHeight
              : 1.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return RepaintBoundary(
              key: _repaintKey,
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: widget.template.backgroundImageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, err) =>
                          Container(color: Colors.grey),
                    ),
                  ),

                  // Dynamic Layers
                  ..._activeLayers.map((layerData) {
                    if (layerData.layer.layerType == 'text') {
                      return Positioned(
                        left: layerData.x,
                        top: layerData.y,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              layerData.x += details.delta.dx;
                              layerData.y += details.delta.dy;
                            });
                          },
                          onDoubleTap: () => _editLayerText(layerData),
                          onScaleStart: (details) {
                            _baseScale = layerData.scale;
                          },
                          onScaleUpdate: (details) {
                            setState(() {
                              // Use focalPointDelta for pan (drag) movement
                              layerData.x += details.focalPointDelta.dx;
                              layerData.y += details.focalPointDelta.dy;
                              // Use scale for pinch-to-zoom
                              if (details.scale != 1.0) {
                                layerData.scale = (_baseScale * details.scale)
                                    .clamp(0.5, 3.0);
                              }
                            });
                          },
                          child: Transform.scale(
                            scale: layerData.scale,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.transparent),
                              ),
                              child: Text(
                                layerData.text,
                                textAlign:
                                    _getTextAlign(layerData.layer.textAlign),
                                style: TextStyle(
                                  color: _hexToColor(layerData.colorHex),
                                  fontSize: layerData.layer.fontSize ?? 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    // Image layer
                    if (layerData.layer.layerType == 'image' &&
                        layerData.layer.imageUrl != null &&
                        layerData.layer.imageUrl!.isNotEmpty) {
                      final imgW =
                          (layerData.layer.width ?? 200) * layerData.scale;
                      final imgH =
                          (layerData.layer.height ?? 200) * layerData.scale;
                      return Positioned(
                        left: layerData.x - imgW / 2,
                        top: layerData.y - imgH / 2,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              layerData.x += details.delta.dx;
                              layerData.y += details.delta.dy;
                            });
                          },
                          onScaleStart: (details) {
                            _baseScale = layerData.scale;
                          },
                          onScaleUpdate: (details) {
                            setState(() {
                              layerData.x += details.focalPointDelta.dx;
                              layerData.y += details.focalPointDelta.dy;
                              if (details.scale != 1.0) {
                                layerData.scale = (_baseScale * details.scale)
                                    .clamp(0.1, 5.0);
                              }
                            });
                          },
                          child: CachedNetworkImage(
                            imageUrl: layerData.layer.imageUrl!,
                            width: imgW,
                            height: imgH,
                            fit: BoxFit.contain,
                            errorWidget: (context, url, err) => Container(
                                width: imgW,
                                height: imgH,
                                color: Colors.transparent),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

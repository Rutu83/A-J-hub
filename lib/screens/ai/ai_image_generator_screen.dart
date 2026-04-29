import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ajhub_app/utils/configs.dart';

class AiImageGeneratorScreen extends StatefulWidget {
  final bool isHelperMode;

  const AiImageGeneratorScreen({super.key, this.isHelperMode = false});

  @override
  State<AiImageGeneratorScreen> createState() => _AiImageGeneratorScreenState();
}

class _AiImageGeneratorScreenState extends State<AiImageGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  String _selectedStyle = 'Realistic';
  bool _isGenerating = false;
  String? _generatedImageUrl;
  String? _errorMessage;

  static const List<String> _styles = [
    'Realistic',
    'Artistic',
    'Cartoon',
    'Oil Painting',
    'Watercolor',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateImage() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt')),
      );
      return;
    }
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedImageUrl = null;
    });
    try {
      final prompt =
          '${_promptController.text.trim()}, style: $_selectedStyle, high quality, professional';
      final response = await http
          .post(
            Uri.parse('https://api.openai.com/v1/images/generations'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $OPENAI_API_KEY',
            },
            body: jsonEncode({
              'model': 'dall-e-3',
              'prompt': prompt,
              'n': 1,
              'size': '1024x1024',
              'quality': 'standard',
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _generatedImageUrl = data['data'][0]['url'] as String);
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _errorMessage =
              (error['error']['message'] as String?) ?? 'Generation failed.';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error. Please try again.');
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _saveImage() async {
    if (_generatedImageUrl == null) return;
    try {
      final res = await http.get(Uri.parse(_generatedImageUrl!));
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/ai_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(res.bodyBytes);
      await GallerySaver.saveImage(path, albumName: 'AJHUB AI');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Saved to gallery!')),
        );
      }
    } catch (_) {}
  }

  Future<void> _shareImage() async {
    if (_generatedImageUrl == null) return;
    try {
      final res = await http.get(Uri.parse(_generatedImageUrl!));
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/ai_share_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(res.bodyBytes);
      await Share.shareXFiles(
        [XFile(path)],
        text: 'Created with AJ Hub AI Image Generator!',
      );
    } catch (_) {}
  }

  Future<void> _addToEditor() async {
    if (_generatedImageUrl == null) return;
    try {
      final res = await http.get(Uri.parse(_generatedImageUrl!));
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/ai_sticker_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(res.bodyBytes);
      if (mounted) {
        Navigator.pop(context, file);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download image')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Image Generator',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        elevation: 0,
      ),
      body: AI_IMAGE_ENABLED ? _buildGenerator() : _buildComingSoon(),
    );
  }

  // ─── Coming Soon Gate ─────────────────────────────────────────────────────
  Widget _buildComingSoon() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // blurred background teaser
        AbsorbPointer(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Opacity(opacity: 0.25, child: _buildFormContent()),
          ),
        ),
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.black.withOpacity(0.35)),
        ),
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 28.w),
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C1F26), Color(0xFF2C2F3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 76.w,
                  height: 76.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFE17055)],
                    ),
                  ),
                  child: Icon(Icons.auto_awesome,
                      color: Colors.white, size: 34.sp),
                ),
                SizedBox(height: 18.h),
                Text(
                  'AI Image Generator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: Colors.redAccent.withOpacity(0.5), width: 1),
                  ),
                  child: Text(
                    '🚀  COMING SOON',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'Generate stunning images from text using best image model.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13.sp,
                    height: 1.55,
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Notify Me When Live 🔔',
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Live Generator ───────────────────────────────────────────────────────
  Widget _buildGenerator() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Describe your image',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        TextField(
          controller: _promptController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'e.g. A professional business poster with flowers and gold accents...',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            filled: true,
          ),
        ),
        SizedBox(height: 16.h),
        Text('Style',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          children: _styles.map((s) {
            final selected = _selectedStyle == s;
            return ChoiceChip(
              label: Text(s),
              selected: selected,
              onSelected: (_) => setState(() => _selectedStyle = s),
              selectedColor: Colors.redAccent,
              labelStyle: TextStyle(color: selected ? Colors.white : null),
            );
          }).toList(),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateImage,
            icon: _isGenerating
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? 'Generating…' : 'Generate Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(_errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 13.sp)),
          ),
        ],
        if (_generatedImageUrl != null) ...[
          SizedBox(height: 20.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.network(_generatedImageUrl!,
                fit: BoxFit.cover, width: double.infinity),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              if (widget.isHelperMode)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addToEditor,
                    icon: const Icon(Icons.add_to_photos),
                    label: const Text('Add to Editor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                )
              else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saveImage,
                    icon: const Icon(Icons.download),
                    label: const Text('Save'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareImage,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

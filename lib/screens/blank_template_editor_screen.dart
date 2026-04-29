import 'dart:io';

import 'package:ajhub_app/screens/editor/photo_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class BlankTemplateEditorScreen extends StatefulWidget {
  const BlankTemplateEditorScreen({super.key});

  @override
  State<BlankTemplateEditorScreen> createState() =>
      _BlankTemplateEditorScreenState();
}

class _BlankTemplateEditorScreenState
    extends State<BlankTemplateEditorScreen> {
  bool _isPicking = false;

  Future<void> _pickAndOpen(ImageSource source) async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final picked = await ImagePicker()
          .pickImage(source: source, imageQuality: 92);
      if (picked != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoEditorScreen.fromFile(
              File(picked.path),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Create Your Own',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildPicker(),
    );
  }

  Widget _buildPicker() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFFF6659)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.add_photo_alternate_outlined,
                size: 44.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Create Your Own Design',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Pick a photo and edit it with the full-featured editor — add text, stickers, filters and more.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 13.sp, height: 1.5),
            ),
            SizedBox(height: 36.h),

            // Gallery Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isPicking ? null : () => _pickAndOpen(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                label: Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  disabledBackgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Camera Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isPicking ? null : () => _pickAndOpen(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                label: Text(
                  'Take a Photo',
                  style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),

            if (_isPicking) ...[
              SizedBox(height: 24.h),
              const CircularProgressIndicator(color: Colors.redAccent),
            ],
          ],
        ),
      ),
    );
  }
}

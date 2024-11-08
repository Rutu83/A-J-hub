// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DownloadedImagesPage extends StatefulWidget {
  const DownloadedImagesPage({super.key});

  @override
  _DownloadedImagesPageState createState() => _DownloadedImagesPageState();
}

class _DownloadedImagesPageState extends State<DownloadedImagesPage> {
  List<File> downloadedImages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedImages();
  }

  Future<void> _loadDownloadedImages() async {
    final directory = Directory('/storage/emulated/0/Pictures/AJHUB');
    if (await directory.exists()) {
      List<FileSystemEntity> files = directory.listSync();
      setState(() {
        downloadedImages = files.whereType<File>().toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle case where directory doesn't exist
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Downloaded Images',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white), // Change icon color to white
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : downloadedImages.isEmpty
          ? const Center(child: Text('No downloaded images found.'))
          : GridView.builder(
        padding: EdgeInsets.all(8.r),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
        ),
        itemCount: downloadedImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Handle image tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImageView(imageFile: downloadedImages[index]),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(
                downloadedImages[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final File imageFile;

  const FullScreenImageView({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image View'),
      ),
      body: Center(
        child: Image.file(
          imageFile,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
          ? _buildNoDataAvailable()

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



  Widget _buildNoDataAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 60,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 10),
          Text(
            'No Download image Available',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}









class FullScreenImageView extends StatefulWidget {
  final File imageFile;

  const FullScreenImageView({super.key, required this.imageFile});

  @override
  _FullScreenImageViewState createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  @override
  void initState() {
    super.initState();
    // Delay showing the share options for a brief moment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          shareToGeneral();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Image View',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              shareToGeneral();
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 100,
          ),
          Image.file(
            widget.imageFile,
            fit: BoxFit.contain,
          ),
        ],
      )
    );
  }



  void shareToWhatsApp() async {
    final String imagePath = widget.imageFile.path;
    final Uri uri = Uri.parse('whatsapp://send?text=Sharing this image&image=$imagePath');

    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      Share.shareXFiles([XFile(imagePath)], text: 'Aj Hub Mobile App');
    }
  }

  void shareToInstagram() async {
    final String imagePath = widget.imageFile.path;
    final Uri uri = Uri.parse('instagram://library?AssetPath=$imagePath');

    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      Share.shareXFiles([XFile(imagePath)], text: 'Aj Hub Mobile App');
    }
  }

  void shareToFacebook() {
    Share.shareXFiles(
      [XFile(widget.imageFile.path)],
      text: 'Aj Hub Mobile App',
    );
  }

  void shareToGeneral() {
    Share.shareXFiles(
      [XFile(widget.imageFile.path)],
      text: 'Aj Hub Mobile App',
    );
  }
}


















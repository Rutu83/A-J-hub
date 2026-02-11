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
    // --- NEW: Request permission before accessing storage ---

    final directory = Directory('/storage/emulated/0/Pictures/AJHUB');
    if (await directory.exists()) {
      // Sort files by modification date, newest first
      List<FileSystemEntity> files = directory.listSync();
      files.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      setState(() {
        downloadedImages = files.whereType<File>().toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // --- NEW: Function to handle image deletion ---
  Future<void> _deleteImage(File imageFile) async {
    // Show a confirmation dialog
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Image'),
          content: const Text(
              'Are you sure you want to permanently delete this image?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
            ),
          ],
        );
      },
    );

    // If user confirmed, proceed with deletion
    if (confirmDelete == true) {
      try {
        if (await imageFile.exists()) {
          await imageFile.delete();
          // Update the UI by removing the file from the list
          setState(() {
            downloadedImages.remove(imageFile);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Image deleted successfully.'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error deleting image: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Images',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
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
                    final imageFile = downloadedImages[index];
                    // --- MODIFIED: Wrap with Stack to add delete button ---
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // The image itself
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullScreenImageView(imageFile: imageFile),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.file(
                              imageFile,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.error));
                              },
                            ),
                          ),
                        ),
                        // The delete button overlay
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _deleteImage(imageFile),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
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
        ));
  }

  void shareToWhatsApp() async {
    final String imagePath = widget.imageFile.path;
    final Uri uri =
        Uri.parse('whatsapp://send?text=Sharing this image&image=$imagePath');

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

import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  KycScreenState createState() => KycScreenState();
}

class KycScreenState extends State<KycScreen> {
  String? _aadharCardFront;
  String? _aadharCardBack;
  String? _panCardFront;
  String? _lightBillFront;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage(Function(File) onImagePicked) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }

  Widget _buildKYCItem(String label, String? frontImageUrl, String? backImageUrl,
      Function(File) onFrontImagePicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.roboto(
                color: Colors.red,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Check if the label is for a required field
            if (label == 'Upload Aadhar Card' || label == 'Upload Pan Card')
              Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 16.sp),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            // Only show the front image upload box for PAN card
            if (label == 'Upload Pan Card')
              _buildKYCUploadBox('Front Page', frontImageUrl, onFrontImagePicked),
            // Show both front and back for Aadhar card
            if (label == 'Upload Aadhar Card') ...[
              _buildKYCUploadBox('Front Page', frontImageUrl, onFrontImagePicked),
              SizedBox(width: 16.w),
              _buildKYCUploadBox('Back Page', backImageUrl, (file) {}),
            ],
          ],
        ),
      ],
    );
  }





  Widget _buildKYCUploadBox(String label, String? imageUrl, Function(File) onImagePicked) {
    return Expanded(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickImage(onImagePicked),
            child: DottedBorder(
              color: Colors.grey,
              strokeWidth: 1,
              dashPattern: const [6, 3], // Customize the dash pattern if needed
              borderType: BorderType.RRect,
              radius: Radius.circular(10.r),
              child: Container(
                height: 100.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: imageUrl == null
                      ? Icon(Icons.add, size: 40.sp, color: Colors.grey)
                      : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: File(imageUrl).existsSync()
                            ? Image.file(
                          File(imageUrl),
                          height: 100.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () => _pickImage(onImagePicked),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _showMissingDocumentsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Missing Required Documents',
            style: GoogleFonts.roboto(
              color: Colors.red,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Please upload at least one ID proof (Aadhar, PAN, or Light Bill) along with your Business Registration Document to complete the KYC process.',
            style: GoogleFonts.roboto(color: Colors.black, fontSize: 16.sp),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateKYC() async {
    if ((_aadharCardFront == null || _aadharCardFront!.isEmpty) &&
        (_panCardFront == null || _panCardFront!.isEmpty) &&
        (_lightBillFront == null || _lightBillFront!.isEmpty)) {
      await _showMissingDocumentsDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Here you would typically handle your KYC update logic

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('KYC Documents Updated', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        duration: Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 7.w,
        elevation: 3,
        centerTitle: true,
        title: Text(
          'KYC Details',
          style: GoogleFonts.roboto(
            color: Colors.red,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 33.h),
              _buildCopyField(),
              SizedBox(height: 33.h),
              _buildKYCItem(
                'Upload Aadhar Card',
                _aadharCardFront,
                _aadharCardBack,
                    (file) {
                  setState(() {
                    _aadharCardFront = file.path; // Save front image
                  });
                },
              ),
              SizedBox(height: 16.h),
              _buildKYCItem(
                'Upload Pan Card',
                _panCardFront,
                null, // No back image for PAN
                    (file) {
                  setState(() {
                    _panCardFront = file.path; // Save front image
                  });
                },
              ),
              SizedBox(height: 35.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: _updateKYC,
                child: Text(
                  'UPLOAD',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCopyField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aadhar Card Number',
          style: GoogleFonts.roboto(
            color: Colors.red,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 12),
            child: const Text(
              '7684 3456 07656',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Pan Card Number',
          style: GoogleFonts.roboto(
            color: Colors.red,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 12),
            child: const Text(
              '2894947538',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

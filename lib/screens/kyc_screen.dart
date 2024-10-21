import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  KycScreenState createState() => KycScreenState();
}

class KycScreenState extends State<KycScreen> {
  String? _aadharCardFront;
  String? _aadharCardBack;
  String? _panCardFront;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _updateKYC() async {
  //   if ((_aadharCardFront == null || _aadharCardFront!.isEmpty) &&
  //       (_panCardFront == null || _panCardFront!.isEmpty) &&
  //       (_lightBillFront == null || _lightBillFront!.isEmpty)) {
  //     await _showMissingDocumentsDialog();
  //     return;
  //   }
  //
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   // Here you would typically handle your KYC update logic
  //
  //   setState(() {
  //     _isLoading = false;
  //   });
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('KYC Documents Updated', style: TextStyle(color: Colors.white)),
  //       backgroundColor: Colors.black,
  //       duration: Duration(milliseconds: 300),
  //     ),
  //   );
  // }

  // Future<void> _showMissingDocumentsDialog() async {
  //   await showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(
  //           'Missing Required Documents',
  //           style: GoogleFonts.roboto(
  //             color: Colors.red,
  //             fontSize: 18.sp,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         content: Text(
  //           'Please upload at least one ID proof (Aadhar, PAN, or Light Bill) along with your Business Registration Document to complete the KYC process.',
  //           style: GoogleFonts.roboto(color: Colors.black, fontSize: 16.sp),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text(
  //               'OK',
  //               style: GoogleFonts.roboto(
  //                 color: Colors.black,
  //                 fontSize: 16.sp,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Future<void> _pickImage(Function(File) onImagePicked) async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //
  //   if (pickedFile != null) {
  //     onImagePicked(File(pickedFile.path));
  //   }
  // }

  // Method to show the bottom sheet
  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.h),
          height: 180.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Image Source',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.red),
                title: Text(
                  'Camera',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.red),
                title: Text(
                  'Gallery',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
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
              style: GoogleFonts.abel(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    offset: const Offset(1.5, 1.0),
                    blurRadius: 1,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
            if (label == 'Upload Aadhar Card' || label == 'Upload Pan Card')
              Text('*', style: TextStyle(color: Colors.red, fontSize: 16.sp)),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            if (label == 'Upload Pan Card')
              _buildKYCUploadBox('Front Page', frontImageUrl, onFrontImagePicked),
            if (label == 'Upload Aadhar Card') ...[
              _buildKYCUploadBox('Front Page', frontImageUrl, onFrontImagePicked),
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
            onTap: () => _showImagePickerBottomSheet(),
            child: DottedBorder(
              color: Colors.grey.shade300,
              strokeWidth: 1,
              dashPattern: const [6, 3],
              borderType: BorderType.RRect,
              radius: Radius.circular(10.r),
              child: Container(
                height: 100.h,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: imageUrl == null
                      ? Icon(Icons.add, size: 40.sp, color: Colors.grey.shade400)
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
                          onTap: () => _showImagePickerBottomSheet(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white, // Set AppBar background color
        elevation: 3, // Add elevation if you want a shadow effect, or set it to 0 for no shadow
        centerTitle: true, // Center the title text
        titleSpacing: 7.w, // Adjust the title spacing using ScreenUtil
        iconTheme: const IconThemeData(
          color: Colors.red, // Set icon color, typically for the back button
        ),
        title: Text(
          'KYC Details',
          style: TextStyle(
            color: Colors.red, // Set title text color to red
            fontSize: 22.sp, // Use ScreenUtil for responsive text size
            fontWeight: FontWeight.w500, // Set the desired font weight
            shadows: [
              Shadow(
                offset: const Offset(1.5, 1.0), // Offset for the shadow effect
                blurRadius: 1,
                color: Colors.grey.shade400, // Subtle shadow color for depth
              ),
            ],
          ),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 16.h,right: 16.h,top: 5.h,bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(22)
                  ),
                  child: _buildCopyField()
              ),
              SizedBox(height: 30.h),
              _buildKYCItem(
                'Upload Aadhar Card',
                _aadharCardFront,
                _aadharCardBack,
                    (file) {
                  setState(() {
                    _aadharCardFront = file.path;
                  });
                },
              ),
              SizedBox(height: 10.h),
              _buildKYCItem(
                'Upload Pan Card',
                _panCardFront,
                null,
                    (file) {
                  setState(() {
                    _panCardFront = file.path;
                  });
                },
              ),

              SizedBox(height: 30.h),
              Center(
                child: SizedBox(
                  width: 350,
                  height: 55,
                  child: Container(
                    decoration: BoxDecoration(
                      //border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.red.shade400,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: const Offset(0, 2), // changes the position of the shadow
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 12),
                    child:   Text(
                      'Upload',
                      style: GoogleFonts.afacad(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            offset: const Offset(1.5, 1.0),
                            blurRadius: 1,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )

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

        const SizedBox(
          height: 6,
        ),

        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info,color: Colors.greenAccent,size: 20,),
            Text(
              'Details',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 9,
        ),


        Padding(
            padding: const EdgeInsets.only(left: 15,right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aadhar Card Number',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Container(
                  decoration: BoxDecoration(
                    //border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red.shade50,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 5,
                        offset: const Offset(0, 2), // changes the position of the shadow
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 12),
                  child:  const Text(
                    '7684 3456 07656',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,

                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 15,
        ),


        Padding(
          padding: const EdgeInsets.only(left: 15,right: 15,bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pan Card Number',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Container(
                  decoration: BoxDecoration(
                    //border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red.shade50,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 5,
                        offset: const Offset(0, 2), // changes the position of the shadow
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 12),
                  child:  const Text(
                    '8767895704',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,

                    ),
                  ),
                ),
              ),
            ],
          ),
        ),


      ],
    );
  }
}

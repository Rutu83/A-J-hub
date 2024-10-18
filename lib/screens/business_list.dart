import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'business_form.dart'; // Import the BusinessForm screen

class BusinessList extends StatelessWidget {
  final String? businessName;
  final String? ownerName;
  final String? mobileNumber;
  final String? email;
  final String? website;
  final String? address;
  final String? selectedCategory;
  final String? state;
  final File? logo;

  const BusinessList({
    super.key,
    this.businessName,
    this.ownerName,
    this.mobileNumber,
    this.email,
    this.website,
    this.address,
    this.selectedCategory,
    this.state,
    this.logo,
  });

  bool get isAllDataNull =>
      (businessName == null || businessName!.isEmpty) &&
          (ownerName == null || ownerName!.isEmpty) &&
          (mobileNumber == null || mobileNumber!.isEmpty) &&
          (email == null || email!.isEmpty) &&
          (website == null || website!.isEmpty) &&
          (address == null || address!.isEmpty) &&
          (selectedCategory == null || selectedCategory!.isEmpty) &&
          (state == null || state!.isEmpty) &&
          logo == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business List'),
        backgroundColor: Colors.white,
      ),
      body: isAllDataNull
          ? Center(
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
              'No Business Data Available',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), // Rounded corners
            color: Colors.white, // Background color
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 9,
                offset: const Offset(0, 3), // Shadow position
              ),
            ],
          ),
          padding: const EdgeInsets.only(left: 16, right: 0, top: 16),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display logo if available
                  if (logo != null)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          logo!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  const SizedBox(width: 10), // Space between image and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBusinessNameRow(businessName ?? 'Not Provided'), // Business name
                        _buildDetailRow(mobileNumber ?? 'Not Provided', isGreen: true), // Mobile number in green
                        _buildDetailRow(state ?? 'Not Provided', isGreen: true), // State in green
                      ],
                    ),
                  ),
                ],
              ),
              // Popup Menu for Edit/Delete options at the top right corner
              Positioned(
                top: 0,
                right: 0,
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Edit') {
                      if (kDebugMode) {
                        print('Edit option selected');
                      }
                    } else if (value == 'Delete') {
                      if (kDebugMode) {
                        print('Delete option selected');
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {'Edit', 'Delete'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to BusinessForm screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BusinessForm()),
          );
        },
        backgroundColor: Colors.red, // Change the color as per your design
        child: const Icon(Icons.add,color: Colors.white,), // Add icon
      ),
    );
  }

  Widget _buildBusinessNameRow(String businessName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            businessName,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 5), // Space between business name and icon
          Image.asset(
            'assets/icons/verified.png',
            width: 15,
            height: 15,
            fit: BoxFit.cover,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: isGreen ? Colors.grey : Colors.black,
        ),
      ),
    );
  }
}

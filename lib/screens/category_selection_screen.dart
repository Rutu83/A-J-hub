// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CategorySelectionScreen extends StatefulWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;

  // Dummy category images for demonstration
  final Map<String, String> categoryImages = {
    'Retail': 'assets/icons/retail.png', // Example path for asset images
    'Food & Beverage': 'assets/icons/restaurant.png',
    'Technology': 'assets/icons/project-management.png',
    'Healthcare': 'assets/icons/healthcare.png',
    'Education': 'assets/icons/school.png',
    'Real Estate': 'assets/icons/house.png',
  };

  CategorySelectionScreen({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  _CategorySelectionScreenState createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Business Category'),
        actions: [
          Text(
            'Skip',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          String category = widget.categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Padding for each item
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), // Rounded corners
                border: Border.all(color: Colors.grey.shade300, width: 1), // Border color and thickness
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(6), // Padding inside ListTile
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50, // Background color for the icon
                    borderRadius: BorderRadius.circular(8), // Border radius for the icon background
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Border radius for rectangular image
                    child: Image.asset(
                      widget.categoryImages[category] ?? 'assets/images/placeholder.png', // Default image fallback
                      width: 40, // Width of the image
                      height: 40, // Height of the image
                      fit: BoxFit.cover, // Fit the image to cover the space
                      color: Colors.red,
                    ),
                  ),
                ),
                title: Text(category),
                onTap: () {
                  // Check if the widget is still mounted before calling the callback
                  if (mounted) {
                    widget.onCategorySelected(category); // Call the callback safely
                  }
                  Navigator.pop(context); // Return to the previous screen
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:allinone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategorySelectionScreen extends StatefulWidget {
  final Function(String, String) onCategorySelected;  // Pass category ID and name

  const CategorySelectionScreen({
    super.key,
    required this.onCategorySelected,
  });

  @override
  _CategorySelectionScreenState createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<Map<String, String>> categories = [];  // List to store category name and ID
  bool isLoading = true;

  final Map<String, String> categoryImages = {
    'Retail': 'assets/icons/retail.png',
    'Food & Beverage': 'assets/icons/restaurant.png',
    'Technology': 'assets/icons/project-management.png',
    'Healthcare': 'assets/icons/healthcare.png',
    'Education': 'assets/icons/school.png',
    'Real Estate': 'assets/icons/house.png',
  };

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    const String url = 'https://ajhub.co.in/api/business-categories';
    String token = appStore.token;  // Replace with your actual token

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          categories = data.map((category) {
            return {
              'id': category['id'].toString(),
              'name': category['name'].toString(),
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      print('Error fetching categories: $error');
      setState(() {
        isLoading = false;
      });
    }
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: Colors.red),
          const SizedBox(width: 10),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String category = categories[index]['name']!;
          String categoryId = categories[index]['id']!;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(6),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      categoryImages[category] ?? 'assets/images/placeholder.jpg',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      color: Colors.red,
                    ),
                  ),
                ),
                title: Text(category),
                onTap: () {
                  widget.onCategorySelected(categoryId, category);  // Pass ID and name
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

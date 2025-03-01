import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/utils/configs.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategorySelectionScreen extends StatefulWidget {
  final Function(String, String) onCategorySelected;

  const CategorySelectionScreen({super.key, required this.onCategorySelected});

  @override
   CategorySelectionScreenState createState() => CategorySelectionScreenState();
}

class  CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<Map<String, String>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    const String url = '${BASE_URL}business-categories';
    String token = appStore.token;
    print(token.length);
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
              'image': category['image'] != null ? 'https://ajhub.co.in/storage/app/public/${category['image']}' : '',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
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
          String categoryName = categories[index]['name']!;
          String categoryId = categories[index]['id']!;
          String imageUrl = categories[index]['image']!;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(6),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/placeholder.jpg',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                      : Image.asset(
                    'assets/images/placeholder.jpg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(categoryName),
                onTap: () {
                  widget.onCategorySelected(categoryId, categoryName);
                  Navigator.pop(context, {
                    'id': categoryId,
                    'name': categoryName,
                    'image': imageUrl,
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

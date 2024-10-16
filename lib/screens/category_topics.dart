import 'package:allinone_app/screens/category_selected.dart';
import 'package:flutter/material.dart';

class CategoryTopics extends StatelessWidget {
  final String title;
  final List<Map<String, String>> images; // Renamed for clarity

  const CategoryTopics({super.key, required this.title, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        elevation: 4.0,
        shadowColor: Colors.grey.withOpacity(0.5),
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 1,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final imageData = images[index]; // Renamed for clarity
            final imageUrl = imageData['image'] ?? ''; // Use imageData

            return InkWell(
              onTap: () {
                // Pass all image URLs when navigating
                List<String> allImageUrls = images.map((imgData) => imgData['image'] ?? '').toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelected(imagePaths: allImageUrls),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200, width: 1.0),
                  borderRadius: BorderRadius.circular(22.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: imageUrl.startsWith('http')
                      ? Image.network(
                         imageUrl,
                         fit: BoxFit.fill,
                         errorBuilder: (context, error, stackTrace) {
                           return Container(
                             color: Colors.grey.shade300,
                             child: const Icon(Icons.error),
                      );
                    },
                  )
                      : Image.asset(
                          imageUrl,
                          fit: BoxFit.fill,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

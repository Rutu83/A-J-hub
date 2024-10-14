import 'package:allinone_app/screens/category_selected.dart';
import 'package:flutter/material.dart';

class CategoryTopics extends StatelessWidget {
  final String title;
  final List<Map<String, String>> topics;

  const CategoryTopics({super.key, required this.title, required this.topics});

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
            childAspectRatio: 1, // Adjusted aspect ratio for square items
          ),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            final imageUrl = topic['image']!; // Image URL or asset path
            final topicTitle = topic['title']!;

            // Map to store image lists based on titles
            Map<String, List<String>> imagesMap = {
              'Navratri': [
                'assets/images/navratri/navratri.jpg',
                'assets/images/navratri/navratri2.jpg',
                // ... other images
              ],
              'Gandhi Jayanti': [
                'assets/images/gandhiji/gandhiji.jpg',
                // ... other images
              ],
              // Add other topics here
            };

            return InkWell(
              onTap: () {
                List<String> images = imagesMap[topicTitle] ?? []; // Get images or empty list

                if (images.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategorySelected(imagePaths: images),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200, width: 1.0),
                  borderRadius: BorderRadius.circular(22.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: imageUrl.startsWith('http') // Check if it's a URL
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.error), // Fallback icon
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
                        child: const Icon(Icons.error), // Fallback icon
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

import 'package:ajhub_app/screens/category_selected.dart';
import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryTopics extends StatelessWidget {
  final String title;
  final List<Map<String, String>>? images;

  const CategoryTopics({super.key, required this.title, required this.images});


  @override
  Widget build(BuildContext context) {

    if (images == null || images!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          surfaceTintColor: Colors.transparent,
          elevation: 4.0,
          shadowColor: Colors.grey.withOpacity(0.5),
          title: Text(title),
        ),
        body: const Center(
          child: Text(
            'No images available.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

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
          itemCount: images!.length,
          itemBuilder: (context, index) {
            final imageData = images![index];
            final imageUrl = imageData['image'] ?? '';

            return InkWell(
              onTap: () {
                List<String> allImageUrls =
                images!.map((imgData) => imgData['image'] ?? '').toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategorySelected(imagePaths: allImageUrls, title: title),
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
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.fill,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.grey[300],
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
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

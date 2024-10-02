import 'package:flutter/material.dart';

class CategoryTopics extends StatelessWidget {
  final String title;

  const CategoryTopics({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        elevation: 4.0, // Set elevation to add shadow
        shadowColor: Colors.grey.withOpacity(0.5), // Optional: customize the shadow color
        title: Text(title),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3 , // Number of columns
            crossAxisSpacing: 2.0, // Spacing between columns
            mainAxisSpacing: 2.0, // Spacing between rows
            childAspectRatio: 2 / 2, // Aspect ratio of the items
          ),
          itemCount: 10, // Number of items in the grid
          itemBuilder: (context, index) {
            return Card(
              color: Colors.grey.shade400, // Set the card color to white
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.0),
              ),
              // child: const GridTile(
              //   child: Icon(
              //     Icons.image,
              //     size: 50.0,
              //     color: Colors.grey,
              //   ),
              // ),
            );

          },
        ),
      ),
    );
  }
}


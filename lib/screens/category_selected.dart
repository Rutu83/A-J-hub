import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CategorySelected extends StatefulWidget {
  final List<String> imagePaths;

  const CategorySelected({super.key, required this.imagePaths});

  @override
  CategorySelectedState createState() => CategorySelectedState();
}

class CategorySelectedState extends State<CategorySelected> {
  int selectedIndex = 0;  // Fixed image index
  int selectedFrameIndex = 0;  // Index for sliding frames

  // Define the available frames
  final List<String> framePaths = [
    'assets/images/fram1.png',  // Add frame1
    'assets/images/fram2.png',
    '/mnt/data/Yw7AIu5jct7REjp5Q2V5q2z2.png',  // Other frame image path
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Select Frame', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              // Handle edit action
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.black),
            onPressed: () {
              // Handle download action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Fixed Image with frame sliding applied
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(6.0),
                height: MediaQuery.of(context).size.height * 0.47,  // Adjust height of the image
                width: MediaQuery.of(context).size.width,  // Full width to remove side gaps
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: _buildImage(widget.imagePaths[selectedIndex]),  // Fixed image
                ),
              ),
              // Frame overlay (selected frame)
              Positioned.fill(
                child: CarouselSlider.builder(
                  itemCount: framePaths.length,
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * 0.47,  // Frame slider height same as the image
                    enableInfiniteScroll: false,  // Disable infinite scroll to avoid repeating frames
                    enlargeCenterPage: false,  // Disable enlargement of frames in the center
                    viewportFraction: 1.0,  // Show only one frame at a time
                    onPageChanged: (index, reason) {
                      setState(() {
                        selectedFrameIndex = index;  // Update frame index
                      });
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    return Image.asset(
                      framePaths[index],  // Apply sliding frames over the fixed image
                      fit: BoxFit.cover,  // Ensure the frame covers the image completely
                    );
                  },
                ),
              ),
            ],
          ),

          // Dots Indicator for the frame slider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: framePaths.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => setState(() {
                  selectedFrameIndex = entry.key;
                }),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedFrameIndex == entry.key
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8.0),

          // Image Grid for selecting different images (if needed)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: widget.imagePaths.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;  // Update image
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4.0,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22.0),
                          child: _buildImage(widget.imagePaths[index]),
                        ),
                      ),
                      if (selectedIndex == index)
                        const Positioned(
                          bottom: 5,
                          right: 5,
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  // Function to build image based on URL or asset path
  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error)); // Fallback for errors
        },
      );
    } else {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error)); // Fallback for errors
        },
      );
    }
  }
}

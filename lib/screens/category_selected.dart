import 'package:allinone_app/screens/business_form.dart';
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
            icon: Image.asset(
              'assets/icons/editing.png',
              width: 30.0,
              height: 30.0,
              color: Colors.black,
            ),
            onPressed: () {
              // Show dialog box for confirmation

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BusinessForm(), // Open BusinessForm
                ),
              );
              // showDialog(
              //   context: context,
              //   builder: (BuildContext context) {
              //     return AlertDialog(
              //       title: const Text('Confirmation'),
              //       content: const Text('Are you sure you want to edit the data?'),
              //       actions: <Widget>[
              //         TextButton(
              //           onPressed: () {
              //             Navigator.of(context).pop(); // Close the dialog
              //           },
              //           child: const Text('Cancel'),
              //         ),
              //         TextButton(
              //           onPressed: () {
              //             Navigator.of(context).pop(); // Close the dialog
              //             Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                 builder: (context) => const BusinessForm(), // Open BusinessForm
              //               ),
              //             );
              //           },
              //           child: const Text('Yes'),
              //         ),
              //       ],
              //     );
              //   },
              // );
            },
          ),

          IconButton(
            icon: Image.asset(
              'assets/icons/download.png',
              width: 35.0,
              height: 35.0,
              color: Colors.black,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
                ),
                backgroundColor: Colors.white,
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Center(
                          child: Container(
                            height: 6,
                            width: 40,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                              borderRadius: BorderRadius.circular(22)
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 30,
                              width: 4,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            const Text(
                              'Aj Hug Pro',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        const Center(
                          child: Text(
                            'Watch a Video or Subscribe to save this \nTemplate',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Handle "Watch Video" action
                              },
                              child: Container(
                                height: 100, // Set a fixed height
                                width: double.infinity, // Set width to fill the available space
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6.0,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child: const Row(
                                  children: [
                                    Icon(Icons.play_circle_fill, size: 50, color: Colors.red),
                                    SizedBox(width: 16.0), // Space between icon and text
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                                      mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                                      children: [
                                        Text(
                                          'Watch Video',
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                        SizedBox(height: 4.0), // Space between the texts
                                        Text(
                                          'To Save This Template', // Updated to show a second line of text
                                          style: TextStyle(fontSize: 14.0, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16.0), // Space between the buttons
                            GestureDetector(
                              onTap: () {
                                // Handle "Save Template" action
                              },
                              child: Container(
                                height: 100, // Set a fixed height
                                width: double.infinity, // Set width to fill the available space
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6.0,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child:  Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/crown.png',
                                      width: 50, // Set the width for the crown icon
                                      height: 50, // Set the height for the crown icon
                                    ),
                                    const SizedBox(width: 16.0), // Space between icon and text
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                                      mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                                      children: [
                                        Text(
                                          'Subscription',
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                        SizedBox(height: 4.0), // Space between the texts
                                        Text(
                                          'Unlock All Pro Template & Remove Ads', // Added descriptive text
                                          style: TextStyle(fontSize: 14.0, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),


                        const SizedBox(height: 20.0),
                      ],
                    ),
                  );
                },
              );
            },
          ),



          const SizedBox(
            width: 10,
          )
        ],

      ),
      body: Column(
        children: [
          // Fixed Image with frame sliding applied
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(6.0),
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

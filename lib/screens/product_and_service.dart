import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/product_detail.dart';
import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OurProductAndService extends StatefulWidget {
  const OurProductAndService({super.key});

  @override
  State<OurProductAndService> createState() => _OurProductAndServiceState();
}

class _OurProductAndServiceState extends State<OurProductAndService> {


  final List<Color> borderColors = [
    Colors.red,
    Colors.blue,
    Colors.pink,
    Colors.orange,
    Colors.purple
  ];

  String data = "Fetching data...";




  List<dynamic> products = [];
  bool hasError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchData(
          (newProducts) {
        setState(() {
          hasError = false;
          products = newProducts;
        });
      },
          (errorMessage) {
        setState(() {
          hasError = true;
          data = errorMessage;
        });
      },
    );
  }



  @override
  Widget build(BuildContext context) {

    if (hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20), // Add padding to the sides
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Network Error Animation with border
                AnimatedOpacity(
                  opacity: hasError ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: 300, // Adjust the width for better responsiveness
                    height: 300, // Adjust the height for better responsiveness
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Colors.red, // Border color
                    //     width: 3, // Border width
                    //   ),
                    //   borderRadius: BorderRadius.circular(12), // Rounded corners
                    // ),
                    child: Lottie.asset(
                      'assets/animation/no_internet_2_lottie.json',
                      width: 350,
                      height: 350,
                    ),
                  ),
                ),

                const SizedBox(height: 30), // Increase spacing

                // Title Text
                const Text(
                  'Oops! Something went wrong.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Slightly darkened text for better contrast
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle Text
                const Text(
                  'Please check your connection and try again.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center, // Center align the text
                ),

                const SizedBox(height: 30), // Increased space between text and button

                // Retry Button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      hasError = false;
                    });
                    fetchData(
                          (newProducts) {
                        setState(() {
                          hasError = false;
                          products = newProducts;
                        });
                      },
                          (errorMessage) {
                        setState(() {
                          hasError = true;
                          data = errorMessage;
                        });
                      },
                    );
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text("Retry", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 18, // Slightly larger font size for better readability
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Our Products & Services',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body:products.isEmpty
          ? Center(
        child: data == "Fetching data..."
            ? buildSkeletonLoader()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 60.sp,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Text(
              'No Data Found',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      )
          :Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final borderColor = borderColors[index % borderColors.length];
                  return InkWell(
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(product: product),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: borderColor.withOpacity(0.15),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  product['thumb_image']!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ?? 1)
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      height: 180,
                                      width: double.infinity,
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),


                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        product['title']!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: borderColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product['short_description']!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailPage(product: product),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    color: borderColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

    );
  }

  Widget buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 130.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16.h,
                    width: 150.w,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12.h,
                    width: 200.w,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}



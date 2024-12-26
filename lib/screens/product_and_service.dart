import 'package:allinone_app/network/rest_apis.dart';
import 'package:allinone_app/screens/product_detail.dart';
import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OurProductAndService extends StatefulWidget {
  const OurProductAndService({super.key});

  @override
  State<OurProductAndService> createState() => _OurProductAndServiceState();
}

class _OurProductAndServiceState extends State<OurProductAndService> {
  List<Map<String, dynamic>> products = [];

  final List<Color> borderColors = [
    Colors.red,
    Colors.blue,
    Colors.pink,
    Colors.orange,
    Colors.purple
  ];

  String data = "Fetching data...";




  @override
  void initState() {
    super.initState();
    fetchData(
          (newProducts) {
        setState(() {
          products = newProducts;
        });
      },
          (errorMessage) {
        setState(() {
          data = errorMessage;
        });
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Our Products & Services',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white, // Set text color to white
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final borderColor = borderColors[index % borderColors.length];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: borderColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: borderColor.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade50,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                product['thumb_image']!,
                                height: 130.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Placeholder when image fails to load
                                  return Container(
                                    color: Colors.grey.shade200, // Background color for placeholder
                                    height: 130.h,
                                    width: double.infinity,
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    )
                                  );
                                },
                              ),
                            ),
                          ),


                          Container(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product['title']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: borderColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
                                    Icons.arrow_right,
                                    color: borderColor,
                                    size: 25.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Product Description
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product['short_description']!,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.black54,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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




import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/utils/configs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});


  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {

  List<String> images = [];
  final TextEditingController _enquiryController = TextEditingController();

  int _currentIndex = 0;
  int userId = 0;
  String firstName = '';
  String email = '';
  String phone = '';

  @override
  void initState() {
    super.initState();

    fetchUserData();
    images = [
      widget.product['thumb_image'],
      widget.product['product_image_1'],
      widget.product['product_image_2'],
      widget.product['product_image_3'],
      widget.product['product_image_4'],
      widget.product['product_image_5'],
    ].where((image) => image != null && image.isNotEmpty).cast<String>().toList();
  }

  void fetchUserData() async {
    try {
      Map<String, dynamic> userDetail = await getUserDetail();


      setState(() {
        userId = userDetail['userId'] ?? '';
        firstName = userDetail['username'] ?? '';
        email = userDetail['email'] ?? '';
        phone = userDetail['phone_number'] ?? '';
      });

    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  void dispose() {
    _enquiryController.dispose();
    super.dispose();
  }



  void _showEnquiryModal() {
    ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submit Your Enquiry',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _enquiryController,
                    maxLines: 3,
                    onChanged: (value) {

                      isButtonEnabled.value = value.trim().isNotEmpty;
                    },
                    decoration: InputDecoration(
                      hintText: 'Type your enquiry here...',
                      hintStyle: GoogleFonts.poppins(fontSize: 14.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: isButtonEnabled,
                    builder: (context, isEnabled, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: isEnabled
                                ? () {
                              final enquiry = _enquiryController.text.trim();
                              Navigator.pop(context);
                              _submitEnquiry(enquiry, widget.product['id']);
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEnabled ? Colors.red : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Submit',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }




  void _submitEnquiry(String enquiry, int productId) async {


    const String apiUrl = "${BASE_URL}submit-inquery";
    String token = appStore.token;

    Map<String, dynamic> requestBody = {
      "user_id": userId,
      "project_id": productId,
      "inquery_note": enquiry,
      "email": email,
      "phone_number": phone,
    };


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.red),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Submitting your enquiry...',
                  style: GoogleFonts.poppins(fontSize: 12.sp),
                ),
              ),
            ],
          ),
        );
      },
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestBody),
      );

      Navigator.of(context, rootNavigator: true).pop();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final successMessage = responseData['message'] ?? 'Enquiry submitted successfully!';
       Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.green,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    successMessage,
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );


      } else {
        Navigator.pop(context);
       final responseData = json.decode(response.body);
        final errorMessage = responseData['message'] ?? 'Failed to submit enquiry. Please try again.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(milliseconds: 5),
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );

      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'An error occurred. Please try again later.',
                  style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
    _enquiryController.clear();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product['title']!,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(
                          text: 'As Promised, We''re The Most Professional ',
                        ),
                        TextSpan(
                          text: '${widget.product['title']}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.red,
                            decorationThickness: 1.0,
                          ),
                        ),
                        const TextSpan(
                          text: '  Company.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    images.isNotEmpty
                        ? CarouselSlider(
                      options: CarouselOptions(
                        height: 400,
                        enlargeCenterPage: true,
                        autoPlay: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        viewportFraction: 1.0,
                      ),
                      items: images.map((imagePath) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(20),

                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 400,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    )
                        : Container(
                      height: 400,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Text(
                          'No Images Available',
                          style: TextStyle(color: Colors.black54, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: images.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => setState(() {
                            _currentIndex = entry.key;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            width: _currentIndex == entry.key ? 12.0 : 8.0,
                            height: 9,
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.red)
                                  .withOpacity(_currentIndex == entry.key ? 0.9 : 0.4),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              )
              ,










              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Column(

                    children: [

                      const Icon(
                        Icons.description,
                        color: Colors.grey,
                        size: 24,
                      ),
                      // const SizedBox(height: 8),

                      //
                      // Center(
                      //   child: Html(
                      //     data: widget.product['description'],
                      //     style: {
                      //       "p": Style(
                      //         fontSize: FontSize(14.sp),
                      //         fontFamily: GoogleFonts.poppins().fontFamily,
                      //         color: Colors.black87,
                      //         fontWeight: FontWeight.w500,
                      //         textAlign: TextAlign.center,
                      //         margin: Margins.only(top: 8,bottom: 0),
                      //       ),
                      //       "strong": Style(
                      //         fontSize: FontSize(16.sp),
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.black,
                      //       ),
                      //       "br": Style(
                      //         whiteSpace: WhiteSpace.pre,
                      //       ),
                      //     },
                      //   ),
                      // ),



                  Center(
                    child: Html(
                      data: cleanHtml(widget.product['description']),
                      style: {
                        "p": Style(
                          fontSize: FontSize(14.sp),
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          textAlign: TextAlign.center,
                          margin: Margins.only(top: 8,bottom: 0),
                        ),
                        "strong": Style(
                          fontSize: FontSize(16.sp),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        "br": Style(
                          whiteSpace: WhiteSpace.normal,
                        ),
                      },
                    ),
                  )

                    ],
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Column(
            //   mainAxisSize: MainAxisSize.min,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //
            //     Text(
            //       'Price',
            //       style: GoogleFonts.poppins(
            //         fontSize: 16.sp,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.black,
            //       ),
            //     ),
            //     const SizedBox(height: 8),

            //     Row(
            //       mainAxisSize: MainAxisSize.min,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         const Icon(
            //           Icons.currency_rupee,
            //           color: Colors.black,
            //           size: 18,
            //         ),
            //         Text(
            //           '499.00',
            //           style: GoogleFonts.poppins(
            //             fontSize: 16.sp,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            const SizedBox(
              width: 30,
            ),
            ElevatedButton.icon(
              onPressed: _showEnquiryModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 20.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                shadowColor: Colors.black,
              ),
              icon: const Icon(Icons.safety_check_rounded, color: Colors.white),
              label: Row(
                children: [
                  Text(
                    'Add Enquire',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                      weight: 55,
                    ),
                  )
                ],
              ),
            ),

          ],
        ),
      ),


    );
  }


  String cleanHtml(String html) {
    return html.replaceAll(RegExp(r'(<br\s*/?>\s*)+'), '<br>').trim();
  }
}

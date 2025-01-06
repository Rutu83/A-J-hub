import 'package:allinone_app/main.dart';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:allinone_app/utils/configs.dart';
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
  // List of images for the slider
  List<String> images = [];
  final TextEditingController _enquiryController = TextEditingController();

  int _currentIndex = 0; // Current index for the slider indicator
  int UserId = 0; // Use Uid as UserId (since it's a string in the response)
  String firstName = ''; // Default value for firstName
  String email = ''; // Default value for email
  String phone = ''; // Store phone as a String

  @override
  void initState() {
    super.initState();

    fetchUserData();
    // Generate the list of images dynamically from product data
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
      if (kDebugMode) {
        print('...........................................................');
        print(userDetail);
      }

      setState(() {
        UserId = userDetail['userId'] ?? ''; // Assign Uid as UserId
        firstName = userDetail['username'] ?? ''; // Default to empty string if null
        email = userDetail['email'] ?? ''; // Default to empty string if null
        phone = userDetail['phone_number'] ?? ''; // Handle phone as String
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
      isScrollControlled: true, // Allow the bottom sheet to resize dynamically
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for the keyboard
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
                      // Enable button if input is not empty
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
                                : null, // Disable button when not enabled
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

    debugPrint("Product ID: $productId");
    debugPrint("Enquiry: $enquiry");
    debugPrint("UserId: $UserId");
    debugPrint("First Name: $firstName");
    debugPrint("Email: $email");
    debugPrint("Phone: $phone");

    const String apiUrl = "${BASE_URL}submit-inquery";
    String token = appStore.token;

    Map<String, dynamic> requestBody = {
      "user_id": UserId,
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
        debugPrint("Enquiry submitted successfully: $responseData");

        Navigator.pop(context);

        // Show success message
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
        // Handle failed submission
        debugPrint("Failed to submit enquiry: ${response.statusCode}, ${response.body}");
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
            duration: const Duration(milliseconds: 5), // Set a shorter duration
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
      // Dismiss the processing dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Handle any exceptions
      debugPrint("Error submitting enquiry: $e");
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

    // Clear the enquiry text field
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
              // Centered Description
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
                            color: Colors.red, // Red color for product name
                            fontWeight: FontWeight.bold, // Optional bold styling
                            decoration: TextDecoration.underline, // Adds a bottom line
                            decorationColor: Colors.red, // Matches the underline color with text color
                            decorationThickness: 1.0, // Thickness of the underline
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

              // Image Slider

              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    images.isNotEmpty
                        ? CarouselSlider(
                      options: CarouselOptions(
                        height: 400, // Fixed height of 450
                        enlargeCenterPage: true,
                        autoPlay: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        viewportFraction: 1.0, // Set this to 1 to make the image take full width
                      ),
                      items: images.map((imagePath) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade200, // Border color
                                  width: 1.0, // Border width
                                ),
                                borderRadius: BorderRadius.circular(20), // Border radius for rounded corners

                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20), // Apply rounded corners to the image
                                child: Image.network(
                                  imagePath,
                                  fit: BoxFit.cover, // Ensure the image fully covers the space
                                  width: double.infinity, // Full width
                                  height: 400, // Fixed height of 450
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade300, // Background color for placeholder
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
                      height: 400, // Fixed height of 450
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Text(
                          'No Images Available',
                          style: TextStyle(color: Colors.black54, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: images.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => setState(() {
                            _currentIndex = entry.key;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200), // Animation duration
                            curve: Curves.easeInOut, // Animation curve
                            width: _currentIndex == entry.key ? 12.0 : 8.0, // Enlarged width for active indicator
                            height: 9, // Constant height
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
                      // Icon for Description
                      const Icon(
                        Icons.description, // Description icon
                        color: Colors.grey, // Icon color
                        size: 24, // Icon size
                      ),
                      // const SizedBox(height: 8), // Space between icon and text
                      // // Product Description



                      //
                      // Center(
                      //   child: Html(
                      //     data: widget.product['description'], // Render HTML content directly
                      //     style: {
                      //       "p": Style(
                      //         fontSize: FontSize(14.sp), // Adjust font size dynamically
                      //         fontFamily: GoogleFonts.poppins().fontFamily, // Use Poppins font
                      //         color: Colors.black87, // Text color
                      //         fontWeight: FontWeight.w500, // Medium weight
                      //         textAlign: TextAlign.center, // Center-align the text
                      //         margin: Margins.only(top: 8,bottom: 0), // Add a margin of 8px at the top
                      //       ),
                      //       "strong": Style(
                      //         fontSize: FontSize(16.sp), // Slightly larger font for bold text
                      //         fontWeight: FontWeight.bold, // Bold style
                      //         color: Colors.black, // Strong emphasis
                      //       ),
                      //       "br": Style(
                      //         whiteSpace: WhiteSpace.pre, // Handle <br> as a normal line break
                      //       ),
                      //     },
                      //   ),
                      // ),



                  Center(
                    child: Html(
                      data: cleanHtml(widget.product['description']), // Preprocess HTML content
                      style: {
                        "p": Style(
                          fontSize: FontSize(14.sp), // Adjust font size dynamically
                          fontFamily: GoogleFonts.poppins().fontFamily, // Use Poppins font
                          color: Colors.black87, // Text color
                          fontWeight: FontWeight.w500, // Medium weight
                          textAlign: TextAlign.center, // Center-align the text
                          margin: Margins.only(top: 8,bottom: 0), // Top margin only
                        ),
                        "strong": Style(
                          fontSize: FontSize(16.sp), // Slightly larger font for bold text
                          fontWeight: FontWeight.bold, // Bold style
                          color: Colors.black, // Strong emphasis
                        ),
                        "br": Style(
                          whiteSpace: WhiteSpace.normal, // Handle <br> as a single line break
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
          color: Colors.white70, // Background color set to light white
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(40), // Rounded top corners
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow color with opacity
              spreadRadius: 2, // Spread radius
              blurRadius: 10, // Blur radius for smoother shadow
              offset: const Offset(0, -3), // Shadow offset (above)
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
            //     // Price Label
            //     Text(
            //       'Price',
            //       style: GoogleFonts.poppins(
            //         fontSize: 16.sp,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.black, // Text color
            //       ),
            //     ),
            //     const SizedBox(height: 8), // Spacing between "Price" and actual price
            //     // Price with Rupee Icon
            //     Row(
            //       mainAxisSize: MainAxisSize.min,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         const Icon(
            //           Icons.currency_rupee,
            //           color: Colors.black, // Icon color
            //           size: 18, // Icon size
            //         ),
            //         Text(
            //           '499.00', // Replace with the dynamic price value
            //           style: GoogleFonts.poppins(
            //             fontSize: 16.sp,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black, // Text color
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
                backgroundColor: Colors.red, // Button color set to grey
                padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 20.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Button border radius
                ),
                elevation: 5, // Add shadow effect
                shadowColor: Colors.black, // Shadow color
              ),
              icon: const Icon(Icons.safety_check_rounded, color: Colors.white), // Add cart icon
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
                  const SizedBox(width: 12), // Space between text and arrow icon
                  Container(
                    padding: const EdgeInsets.all(8.0), // Padding around the icon
                    decoration: BoxDecoration(
                      color: Colors.white54, // Background color
                      shape: BoxShape.circle, // Circular background
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          blurRadius: 4, // Blur radius
                          offset: const Offset(2, 2), // Shadow offset
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white, // Icon color
                      size: 20, // Icon size
                      weight: 55, // Icon stroke weight (if supported in your Flutter version)
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
    // Remove excessive <br> tags and trim spaces
    return html.replaceAll(RegExp(r'(<br\s*/?>\s*)+'), '<br>').trim();
  }
}

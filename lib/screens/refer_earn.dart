import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening WhatsApp

class ReferEarn extends StatefulWidget {
  const ReferEarn({super.key});

  @override
  State<ReferEarn> createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> {
  @override
  void initState() {
    super.initState();
    // Set the status bar icon and text color to white and make it transparent
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Makes status bar transparent
      statusBarIconBrightness: Brightness.light, // Sets icons to light color (white)
      statusBarBrightness: Brightness.dark, // For iOS devices, sets status bar content to dark
    ));
  }

  // Function to open WhatsApp with the referral code
  Future<void> _shareOnWhatsApp(String message) async {
    final url = 'https://wa.me/?text=$message';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.red,
        elevation: 0, // Removes shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Refer & Earn',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            height: 40,
            width: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Image.asset('assets/images/wallet.png'),
          ),
          const SizedBox(width: 10), // Adds spacing between the image and right side
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImage('assets/images/refer_earn.png'),
            _buildCopyField(),
            const SizedBox(height: 30),
            _buildButton(),

          ],
        ),
      ),
    );
  }

  // Image Widget
  Widget _buildImage(String assetPath) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Image.asset(assetPath),
    );
  }

  // Copy Field Widget
  Widget _buildCopyField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        padding: const EdgeInsets.all(4),
        color: Colors.red,
        strokeWidth: 2,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Your Referral Code: 12345',
                  style: TextStyle(fontSize: 16.0.sp, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  // Implement copy functionality here
                },
                icon: const Icon(Icons.copy, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add padding to the whole row
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space buttons evenly
        children: [
          // First Button: Refer Now
          Expanded(
            child: Container(
              height: 70, // Height of the button
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20.r), // Smoother radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8, // Increased blur for a subtle effect
                    offset: const Offset(0, 4), // Adjust shadow offset
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Implement your action here for "Refer Now"
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  )),
                  elevation: WidgetStateProperty.all(0), // Remove internal shadow
                ),
                child: const Center(
                  child: Text(
                    'Refer Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Second Button: WhatsApp Icon Button
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                _shareOnWhatsApp('Check out my referral code: 12345');
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.green),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                )),
                elevation: WidgetStateProperty.all(0), // No internal shadow
              ),
              child: Image.asset(
                'assets/images/whatsapp.png', // Make sure to use a suitable WhatsApp icon
                width: 40, // Adjust size of the icon
                height: 40, // Adjust size of the icon
              ),
            ),
          ),
        ],
      ),
    );
  }
}

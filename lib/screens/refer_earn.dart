import 'package:allinone_app/network/rest_apis.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferEarn extends StatefulWidget {
  const ReferEarn({super.key});

  @override
  State<ReferEarn> createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> {
  bool _isLoading = true;
  String referralCode = "Loading...";

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.light, // Light-colored icons
      statusBarBrightness: Brightness.dark, // Dark content for iOS
    ));

    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> userDetail = await getUserDetail();

      setState(() {
        referralCode = userDetail['referral_code'] ?? 'Unavailable';
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
      setState(() {
        _isLoading = false;
      });
    }
  }



  Future<void> _shareOnWhatsApp(String referralCode) async {
    // Create the custom message with the referral code
    final String message = '''
*Join AJHub today and unlock exciting benefits!* 🚀

Greetings! 🎉 I have become a primary member of AJHub. You too can join and start earning ₹200 for every successful Promote Sign up using my referral code: $referralCode 💸 Build your Circle, grow your network, and unlock even more earning potential! 📈

Start Promoting today and maximize your income! 💰

*Referral Code*: $referralCode 🔑
''';

    // Encode the message to handle spaces and special characters
    final String encodedMessage = Uri.encodeComponent(message);
    final String url = 'https://wa.me/?text=$encodedMessage';

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
        title: Text(
          'Refer & Earn',
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

      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.red,
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImage('assets/images/refer_earn.png'),
            _buildCopyField(),
            const SizedBox(height: 30),
            _buildButtonRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCopyField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: [8, 4], // Customize the dash pattern
        color: Colors.red,
        strokeWidth: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.red.shade50, // Light background for contrast
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Your Referral Code: $referralCode',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade900, // Darker red for better readability
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: referralCode)).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Referral code copied to clipboard!',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        backgroundColor: Colors.green.shade700,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.copy, color: Colors.red),
                tooltip: 'Copy Referral Code',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _shareOnWhatsApp(referralCode);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                shadowColor: Colors.red.withOpacity(0.4),
              ),
              child: Text(
                'Refer Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              _shareOnWhatsApp(referralCode);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              shadowColor: Colors.grey.withOpacity(0.2),
            ),
            child: Image.asset(
              'assets/images/whatsapp2.png', // Use a high-resolution WhatsApp icon
              width: 36, // Adjust the size
              height: 36, // Adjust the size
            ),
          ),
        ],
      ),
    );
  }

}

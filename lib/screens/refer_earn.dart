import 'package:allinone_app/network/rest_apis.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Refer & Earn',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        color: Colors.red,
        strokeWidth: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Your Referral Code: $referralCode',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: referralCode)).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Referral code copied to clipboard!')),
                    );
                  });
                },
                icon: const Icon(Icons.copy, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _shareOnWhatsApp(referralCode);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Refer Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          ElevatedButton(
            onPressed: () {
              _shareOnWhatsApp(referralCode);
            },
            style: ButtonStyle(
             backgroundColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              )),
             elevation: WidgetStateProperty.all(0), // No internal shadow
            ),
            child: Image.asset(
              'assets/images/whatsapp2.png', // Make sure to use a suitable WhatsApp icon
              width: 70, // Adjust size of the icon
              height: 70, // Adjust size of the icon
            ),
          ),

        ],
      ),
    );
  }
}

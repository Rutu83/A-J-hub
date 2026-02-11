import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  FAQPageState createState() => FAQPageState();
}

class FAQPageState extends State<FAQPage> {
  final List<Map<String, String>> faqList = [
    {
      "question": "How do I use the AJ Hub app?",
      "answer":
          "You can explore music, audiobooks, and the poster maker by navigating through the app's home menu. Each section has guided steps to help you get started."
    },
    {
      "question": "Can I update my profile details in AJ Hub?",
      "answer":
          "Yes, you can update your name and other details under the \"Profile\" section in the app settings."
    },
    {
      "question":
          "Can I log in to AJ Hub with multiple accounts on one device?",
      "answer":
          "Currently, you can only use one account per device. If needed, log out and log in with a different account."
    },
    {
      "question": "AJ Hub is not functioning properly. Can you assist me?",
      "answer":
          "Please ensure your app is updated to the latest version and check your internet connection. If the issue persists, contact us via the support option in the app."
    },
    {
      "question": "Can I create professional posters with AJ Hub in minutes?",
      "answer":
          "Yes, the Poster Maker feature offers templates and tools to design high-quality posters in a few simple steps."
    },
    {
      "question": "How does the AJ Hub referral program work?",
      "answer":
          "Invite friends to join AJ Hub using your unique referral code. Earn rewards benefits when they sign up and use the app."
    },
    {
      "question": "What promise does AJ Hub make to its users?",
      "answer":
          "We are committed to providing an exceptional platform for creativity, learning, and growth, ensuring a seamless experience for every user."
    },
    {
      "question": "How can I contact AJ Hub for support?",
      "answer":
          "You can reach out to us directly via the \"Contact Us\" section or tap the WhatsApp icon for instant help."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Frequently Asked Questions',
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              itemCount: faqList.length,
              itemBuilder: (context, index) {
                final item = faqList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1.0,
                      ),
                    ),
                    child: ExpansionTile(
                      iconColor: Colors.red,
                      collapsedIconColor: Colors.black45,
                      collapsedBackgroundColor: Colors.grey.shade50,
                      backgroundColor: Colors.grey.shade100,
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      title: Row(
                        children: [
                          Icon(
                            Icons.support_agent,
                            color: Colors.red.shade500,
                            size: 20.0,
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Text(
                              item["question"]!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16.0),
                              bottomRight: Radius.circular(16.0),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Text(
                            item["answer"]!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: ElevatedButton.icon(
              onPressed: _openWhatsApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                elevation: 8,
                shadowColor: Colors.green.withOpacity(0.3),
              ),
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Image.asset(
                    'assets/icons/whatsapp.png',
                    height: 20,
                    width: 20,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              label: const Text(
                "Chat with Us",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openWhatsApp() async {
    const phone = "+917863045542";
    final message = Uri.encodeComponent("Hi, I need support!");
    final whatsappUrl = "https://wa.me/$phone?text=$message";

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Could not open WhatsApp. Please ensure it is installed.")),
      );
    }
  }
}

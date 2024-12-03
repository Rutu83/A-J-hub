import 'package:flutter/material.dart';
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
      "question": "Can I log in to AJ Hub with multiple accounts on one device?",
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
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.keyboard_backspace),
        ),
        title: const Text(
          "Frequently Asked Questions",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: faqList.length,
              itemBuilder: (context, index) {
                final item = faqList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.grey.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: Colors.red.withOpacity(0.3),
                        width: 1.0,
                      ),
                    ),
                    child: ExpansionTile(
                      iconColor: Colors.red,
                      collapsedIconColor: Colors.black54,
                      title: Text(
                        item["question"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            item["answer"]!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.5,
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
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: ElevatedButton.icon(
              onPressed: _openWhatsApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 6,
                shadowColor: Colors.grey.withOpacity(0.4),
              ),
              icon: Image.asset(
                'assets/icons/whatsapp.png',
                height: 24,
                width: 24,
                fit: BoxFit.contain,
              ),
              label: const Text(
                "Reach out to us",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
    const phone = "919662545518";
    final message = Uri.encodeComponent("Hi, I need support!");
    final whatsappUrl = "https://wa.me/$phone?text=$message";

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Could not open WhatsApp. Please ensure it is installed.")),
      );
    }
  }
}

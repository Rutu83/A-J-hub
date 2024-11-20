import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<Map<String, String>> faqList = [
    {
      "question": "How do I practice with Sivi?",
      "answer":
      "To practice with Sivi, you can access interactive modules designed to improve your skills. These modules include step-by-step exercises, quizzes, and practical activities to ensure an engaging learning experience."
    },
    {
      "question": "Can I update my name and gender in the App?",
      "answer":
      "Yes, you can update your name and gender in the profile section of the app. Simply go to 'My Profile', select the edit option, and update your details. Make sure to save the changes for them to reflect in your account."
    },
    {
      "question": "Can I sign up multiple times with different numbers on one mobile?",
      "answer":
      "No, the app allows only one account per mobile device. This ensures the security of your data and prevents misuse. If you need to switch accounts, log out and log in with a different number."
    },
    {
      "question": "Sivi is not working properly. Can you help?",
      "answer":
      "If Sivi is not functioning properly, try restarting the app or your device. Ensure you have a stable internet connection. If the issue persists, contact our support team via the 'Help & Support' section in the app."
    },
    {
      "question": "Can I learn English in 30 days?",
      "answer":
      "Learning English in 30 days depends on your effort and consistency. Sivi provides structured tools like daily lessons, quizzes, and vocabulary-building exercises to help you improve quickly. Dedicate time each day for best results."
    },
    {
      "question": "What are Sivi coins, and how do I earn more coins?",
      "answer":
      "Sivi coins are rewards for completing activities in the app, such as finishing lessons, quizzes, and challenges. You can earn more coins by staying consistent and actively engaging with the app's features."
    },
    {
      "question": "A promise from the Sivi Team",
      "answer":
      "We promise to provide a personalized and effective learning experience tailored to your goals. Our team is committed to supporting you with high-quality content, interactive features, and timely updates."
    },
  ];




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: (){
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
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: ElevatedButton.icon(
              onPressed: _openWhatsApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // WhatsApp branding color
                padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // Rounded edges for a smooth look
                ),
                elevation: 6, // Subtle shadow for a raised effect
                shadowColor: Colors.grey.withOpacity(0.4), // Light shadow
              ),
              icon: Image.asset(
                'assets/icons/whatsapp.png',
                height: 24, // Adjust height
                width: 24, // Adjust width
                fit: BoxFit.contain,
              ),
              label: const Text(
                "Reach out to us",
                style: TextStyle(
                  fontSize: 18, // Slightly larger text for readability
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // White text for contrast against green background
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }

  void _openWhatsApp() async {
    const phone = "919662545518"; // Replace with your number (in international format)
    final message = Uri.encodeComponent("Hi, I need support!");
    final whatsappUrl = "https://wa.me/$phone?text=$message";

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open WhatsApp. Please ensure it is installed.")),
      );
    }
  }
}

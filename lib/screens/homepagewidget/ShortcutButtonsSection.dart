import 'package:ajhub_app/screens/refer_earn.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ShortcutButtonsSection extends StatelessWidget {
  const ShortcutButtonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width / 3.5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton(
            context,
            Icons.share,
            'Refer',
            383, // Set your desired button width
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReferEarn()),
              );
            },
          ),
          // _buildButton(context, Icons.favorite, 'Charity', buttonWidth, () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => const CharityScreen()),
          //   );
          // }),
          // _buildButton(context, Icons.group, 'Community', buttonWidth, () {
          //   _openWhatsAppGroup(context);
          // }),
        ],
      ),
    );
  }

  _buildButton(BuildContext context, IconData icon, String label,
      double buttonWidth, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: buttonWidth,
        height: 140,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/img_3.jpg'), // Set your banner image here
            fit: BoxFit.fitWidth,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(
            //   icon,
            //   color: Colors
            //       .white, // Icon color (you can adjust based on your banner)
            // ),
            // const SizedBox(width: 10), // Space between icon and text
            // Text(
            //   label,
            //   style: const TextStyle(
            //     color: Colors
            //         .white, // Text color (you can adjust based on your banner)
            //     fontSize: 16,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _openWhatsAppGroup(BuildContext context) async {
    const groupLink = "https://chat.whatsapp.com/K50pflHRu6EB1IXSpKOrbl";

    try {
      if (await canLaunchUrl(Uri.parse(groupLink))) {
        await launchUrl(Uri.parse(groupLink),
            mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't open WhatsApp group."),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}

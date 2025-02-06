import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

        backgroundColor: Colors.red,
        titleSpacing: 7.w,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Contact Us',
          style: TextStyle(
            fontSize: 20.0.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildImage('assets/images/contact_us.jpg'),
            const SizedBox(height: 20),
            buildTitle(),
            const SizedBox(height: 20),
            buildContactField(),
          ],
        ),
      ),
    );
  }

  Widget buildImage(String imageUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topRight: Radius.circular(90)),
      child: Image.asset(imageUrl, height: 350, width: double.infinity, fit: BoxFit.fill),
    );
  }

  Widget buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Contact Us on below details',
          style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          'Customer Care Details (10 AM to 06 PM - Mon to Sat)',
          style: GoogleFonts.roboto(fontSize: 15, color: Colors.grey),
        ),
      ],
    );
  }

  Widget buildContactField() {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        buildContactContainer(
          iconPath: 'assets/icons/whatsapp.png',
          contactInfo: '99258 50305',
          onTap: () => _launchUrl('https://wa.me/99258 50305'),
        ),
        const SizedBox(
          height: 20,
        ),
        buildContactContainer(
          iconPath: 'assets/images/gmail.png',
          contactInfo: 'support@ajhub.co.in',
          onTap: () => _launchUrl('mailto:support@ajhub.co.in'),
        ),
      ],
    );
  }

  Widget buildContactContainer({required String iconPath, required String contactInfo, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(iconPath, height: 30, width: 30),
            const SizedBox(width: 10),
            Text(contactInfo, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }



  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

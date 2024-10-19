// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: [

            Stack(
              children: [
                Container(
                  height: 350,
                ),
                Positioned(
                  child:_buildAppBar(),
                ),
                Positioned(
                  top: 100, // Adjust this value to control the position of the second container
                  left: 0,
                  right: 0,
                  child:  buildImage('assets/images/contact.jpg'),
                ),
              ],
            ),

          //  buildImage('assets/images/contact_us.jpg'),
            buildTitle(),
            buildContactField(),

          ],
        ),
      ),
    );
  }


  Widget _buildAppBar() {
    return  Container(
      width: double.infinity,
      height: 130,
      padding: const EdgeInsets.only(left: 10,right: 10,top: 30,bottom: 30),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: const BorderRadius.only( bottomLeft: Radius.circular(400.0),bottomRight:  Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color with opacity
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: const Offset(0, 3), // Shadow offset: horizontal, vertical
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            child:  const Icon(Icons.arrow_back_sharp,color: Colors.white,size: 30,),
          ),

          const SizedBox(
            width: 20,
          ),
          const Text('Contact Us',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
        ],
      ),
    );
  }

  Widget buildImage(String imageUrl) {
    return Container(
      height: 200,
      width: 150,
      padding: const EdgeInsets.only(left: 10, right: 50),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topRight: Radius.circular(90)), // Optional: Rounded corners
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topRight: Radius.circular(90)),
        child: imageUrl.startsWith('assets/')
            ? Image.asset(
          imageUrl,
          fit: BoxFit.fill,
        )
            : Image.network(
          imageUrl,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error); // Fallback in case of error
          },
        ),
      ),
    );

  }

  // Builds the title section
  Widget buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Contact Us on below details',
          style: GoogleFonts.roboto(
            fontSize: 22.0.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          'Customer Care Details (10 AM to',
          style: GoogleFonts.roboto(
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
        Text(
          '06 PM - Mon to Sat)',
          style: GoogleFonts.roboto(
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Builds the contact details fields with click actions
  Widget buildContactField() {
    return Column(
      children: [

        buildContactContainer(
          iconPath: 'assets/icons/whatsapp.png',
          contactInfo: '8787878787',
          onTap: () => _launchUrl('https://wa.me/8787878787'), // Opens WhatsApp
        ),
        buildContactContainer(
          iconPath: 'assets/images/gmail.png',
          contactInfo: 'xyz@gmail.com',
          onTap: () => _launchUrl('mailto:xyz@gmail.com'), // Opens email client
        ),
      ],
    );
  }

  // Helper method to build each contact container
  Widget buildContactContainer({
    required String iconPath,
    required String contactInfo,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, top: 30, bottom: 10),
      child: GestureDetector(
        onTap: onTap, // Add onTap event handler
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(11)),
            border: Border.all(color: Colors.red.shade50),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.15), // Soft shadow
                blurRadius: 10, // Smooth blur
                offset: const Offset(0, 4), // Vertical offset for depth
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Image.asset(
                  iconPath,
                  height: 30,
                  width: 30,
                ),
              ),
              const SizedBox(width: 10), // Adds spacing between image and text
              Text(
                contactInfo,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Builds the title section
  Widget buildButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, top: 40, bottom: 10),
      child:Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.red,
          border: Border.all(color: Colors.red.shade50),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color with opacity
              blurRadius: 12, // How much to blur the shadow
              offset: const Offset(0, 4), // Offset the shadow vertically
            ),
          ],
        ),
        child: Text(
          'Raise a Ticket',
          style: GoogleFonts.roboto(
            fontSize: 12.0.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      )
    );
  }

  // Method to handle URL launching
  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

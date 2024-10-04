import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferEarn extends StatefulWidget {
  const ReferEarn({super.key});

  @override
  State<ReferEarn> createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        titleSpacing: 7.w,
        title: Text(
          'Refer & Earn',
          style: GoogleFonts.roboto(
            fontSize: 16.0.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildWalletBox("₹ 10,000", "Current Wallet", Colors.grey.shade50),
            _buildMessage(),
            _buildImage('assets/images/refer.jpg'),
            _buildCopyField(),
            _buildButton(),

            SizedBox(
              height: 10,
            ),

            InkWell(
              onTap: () => launchUrl(Uri.parse('https://www.google.com')),
              child: Text(
                'View Refer & Earn Policy',
                style: TextStyle(decoration: TextDecoration.underline, color: Colors.red, fontSize: 14.0.sp,
                  fontWeight: FontWeight.bold,),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade50),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 250.w,
            height: 250.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: imageUrl.startsWith('assets/')
                  ? Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              )
                  : Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildWalletBox(String amount, String label, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
      margin: const EdgeInsets.only(left: 27,right: 27),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Text(
                    'Current Wallet',
                    style: GoogleFonts.poppins(
                        fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.red),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.info_outline, color: Colors.red),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                amount,
                style: GoogleFonts.poppins(
                    fontSize: 25.sp, fontWeight: FontWeight.w700, color: Colors.red),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.red, size: 12),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 100,
            child: VerticalDivider(color: Colors.red, width: 2),
          ),
          Column(
            children: [
              Row(
                children: [
                  Text(
                    'Current Wallet',
                    style: GoogleFonts.poppins(
                        fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.red),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.info_outline, color: Colors.red),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                amount,
                style: GoogleFonts.poppins(
                    fontSize: 25.sp, fontWeight: FontWeight.w700, color: Colors.red),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.red, size: 12),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 44,right: 44,top: 20,bottom: 5),
      child: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🔴  ',
                style: TextStyle(
                    fontSize: 11
                ),),
              Flexible(
                child: Text(
                  'The horizontal rule represents as rules are used only after main sections, and this.',
                  softWrap: true,
                  style: TextStyle(
                      color: Colors.black26,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: 20.h),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🔴  ',
                style: TextStyle(
                  fontSize: 11
                ),),
              Flexible(
                child: Text(
                  'The horizontal rule represents a paragraph-level thematic break. Do not use in article content, as rules are used only after main sections, and this is automatic.',
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.black26,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCopyField() {
    return Container(
      margin: const EdgeInsets.only(left: 27, right: 27, top: 20),
      width: double.infinity,
      height: 55,
      child: DottedBorder(
        color: Colors.red, // Border color
        strokeWidth: 1, // Border width
        dashPattern: [6, 3], // Dash pattern: [dash length, space length]
        borderType: BorderType.RRect, // Rounded rectangle
        radius: const Radius.circular(12), // Border radius
        child: Container(
          color: Colors.white, // Background color of the inner container
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 12),
          child:  const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'J3D85',
                style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.bold),
              ),
              Padding(
                  padding: EdgeInsets.only(right: 20),
              child:    Icon(Icons.copy),
              )


            ],
          )
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Row(
      children: [
        // First Button Container
        Container(
          margin: const EdgeInsets.only(left: 25, top: 20, right: 10),
          width: 300,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                spreadRadius: 2, // Spread radius
                blurRadius: 5, // Blur radius
                offset: const Offset(0, 3), // Shadow offset: horizontal, vertical
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Refer Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Second Button Container
        Container(
          margin: const EdgeInsets.only(right: 25, top: 20),
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                spreadRadius: 2, // Spread radius
                blurRadius: 5, // Blur radius
                offset: const Offset(0, 3), // Shadow offset: horizontal, vertical
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/whatsapp.png',
          ),
        ),
      ],
    );
  }


}


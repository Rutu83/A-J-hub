import 'package:dotted_border/dotted_border.dart';
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Stack(
              children: [

                Container(
                  height: 270,
                ),
                Positioned(
                  child:_buildAppBar(),
                ),


                Positioned(
                  top: 100, // Adjust this value to control the position of the second container
                  left: 0,
                  right: 0,
                  child: _buildCustomContainer(Colors.white, '₹1234', 'Label Text'),
                ),
              ],
            ),

            _buildMessage(),
            _buildImage('assets/images/refer.jpg'),
            _buildCopyField(),
            _buildButton(),

            const SizedBox(
              height: 30,
            ),

            // InkWell(
            // //  onTap: () => launchUrl(Uri.parse('https://www.ajhub.co.in/referernpage')),
            //   child: Text(
            //     'View Refer & Earn Policy',
            //     style: TextStyle(decoration: TextDecoration.underline, color: Colors.red, fontSize: 14.0.sp,
            //       fontWeight: FontWeight.bold,),
            //   ),
            // )
          ],
        ),
      ),
    );
  }


  Widget _buildCustomContainer(Color color, String amount, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
      margin: const EdgeInsets.only(left: 27, right: 27),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25.0),
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
                        fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.red),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.info_outline, color: Colors.red),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                amount,
                style: GoogleFonts.poppins(
                    fontSize: 25.0, fontWeight: FontWeight.w700, color: Colors.red),
              ),
              const SizedBox(height: 10.0),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: const BorderRadius.all(Radius.circular(22))
                ),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                          fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.red, size: 12),
                  ],
                ),
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
                        fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.red),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.info_outline, color: Colors.red),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                amount,
                style: GoogleFonts.poppins(
                    fontSize: 25.0, fontWeight: FontWeight.w700, color: Colors.red),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: const BorderRadius.all(Radius.circular(22))
                ),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                          fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.red, size: 12),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildAppBar() {
    return  Container(
      width: double.infinity,
      height: 170,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            child:  const Icon(Icons.arrow_back_sharp,color: Colors.white,size: 30,),
          ),

          const Text('Refer & Earn',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),


          Container(
            height: 40,
            width: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              color: Colors.white,
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
              'assets/images/wallet.png',
            ),
          ),


          //  const Icon(Icons.wallet,color: Colors.white,size: 30,),
        ],
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
                  'When your friends registers on the app , You receive ₹100, and your friend receives ₹100. As a AllInOne HUb Point',
                  softWrap: true,
                  style: TextStyle(
                      color: Colors.black26,
                    fontWeight: FontWeight.bold,
                      fontSize: 15
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: 18.h),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🔴  ',
                style: TextStyle(
                  fontSize: 11
                ),),
              Flexible(
                child: Text(
                  'When your friends pays for a premium package , You receive a 10% as a cash balance.',
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.black26,
                      fontWeight: FontWeight.bold,
                      fontSize: 15
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
        dashPattern: const [6, 3], // Dash pattern: [dash length, space length]
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
                color: Colors.black.withOpacity(0.1), // Shadow color with opacity
                spreadRadius: 1, // Spread radius
                blurRadius: 5, // Blur radius
                offset: const Offset(0, 0), // Shadow offset: horizontal, vertical
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


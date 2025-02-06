// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupport extends StatefulWidget {
  const HelpSupport({super.key});

  @override
  State<HelpSupport> createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport> {
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
                  top: 100,
                  left: 0,
                  right: 0,
                  child:  buildImage('assets/images/help_support.jpg'),
                ),
              ],
            ),

            const SizedBox(height: 20,),
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
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
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
            const Text('Help and support',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
        ],
      ),
    );
  }

  Widget buildImage(String imageUrl) {
    return Container(
      height: 250,
      width: 390,
      padding: const EdgeInsets.only(left: 10, right: 50),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topRight: Radius.circular(90)),
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
            return const Icon(Icons.error);
          },
        ),
      ),
    );

  }

  Widget buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'How we can help you ?',
          style: GoogleFonts.roboto(
            fontSize: 22.0.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          'if you need instant support then use live',
          style: GoogleFonts.roboto(
            fontSize: 12.0.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
        Text(
          'chat or reach us quickly',
          style: GoogleFonts.roboto(
            fontSize: 12.0.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget buildContactField() {
    return Column(
      children: [
        buildContactContainer(
          iconPath: 'assets/images/backlog.png',
          contactInfo: 'Frequently Asked Questions',
          onTap: (){},
        ),
        buildContactContainer(
          iconPath: 'assets/images/contact-book.png',
          contactInfo: 'Raise a Ticket',
          onTap: (){},
        ),
        buildContactContainer(
          iconPath: 'assets/images/customer-service.png',
          contactInfo: 'Contact Us',
          onTap: (){},
        ),
        buildContactContainer(
          iconPath: 'assets/images/review.png',
          contactInfo: 'Feedback',
          onTap: (){},
        ),
      ],
    );
  }

  Widget buildContactContainer({
    required String iconPath,
    required String contactInfo,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 65,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            border: Border.all(color: Colors.red.shade50),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.10),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [

              const SizedBox(width: 10),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child:  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7,vertical: 7),
                  child: Image.asset(
                    iconPath,
                    color: Colors.white,
                    height: 30,
                    width: 30,
                  ),
                ),
              ),

              const SizedBox(width: 10),
              Text(
                contactInfo,
                style: const TextStyle(fontSize: 16),
              ),
              
              const Spacer(flex: 1,),

              const Icon(Icons.arrow_forward_ios_sharp,size: 20,weight: 1,color: Colors.black54,),
               const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }


}

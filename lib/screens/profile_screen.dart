
import 'package:allinone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text(
      //     "Profile",
      //     style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w600),
      //   ),
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.white,
      // ),
      body:  SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 12.0,bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              CircleAvatar(
                radius: 33.r,
                backgroundColor: Colors.indigoAccent.withOpacity(0.2),
                child: Icon(Icons.person_outline, size: 60.sp, color: Colors.red),
              ),
              SizedBox(height: 6.h),
              Text(
                appStore.Name,
                style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.h),
              Text(
                'divyabhachani07@gmail.com',
                style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Colors.black87),
              ),
              SizedBox(height: 10.h),
              InkWell(
                onTap: () {

                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5.h),
                  padding: const EdgeInsets.only(left: 15,right: 15,top: 15,bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'My Profile',
                        style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios_outlined, color: Colors.black54, size: 18.sp),
                    ],
                  ),
                ),
              ),
              _buildOptionRow('Plan Pdf ', Icons.picture_as_pdf),
              _buildOptionRow('Kyc Details', Icons.account_balance_outlined),
              _buildOptionRow('Transaction Report', Icons.receipt_long_rounded),
              _buildOptionRow('Income Report', Icons.receipt_long_rounded),
              _buildOptionRow('Change Password', Icons.lock_clock_outlined),
              _buildOptionRow('Change Transaction Password', Icons.lock_clock_outlined),
              _buildOptionRow('Share', Icons.share),
              _buildOptionRow('About Us', Icons.info_outline),
              SizedBox(height: 25.h),
              InkWell(
                onTap: () async {

                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
                  margin: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      'Log out',
                      style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25.h),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow(String title, IconData icon) {
    return InkWell(
      onTap: (){
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ChangePasswordScreen(),
        //   ),
        // );
      },
      child: Container(
        margin: EdgeInsets.only(top: 10.h),
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 18.sp),
            SizedBox(width: 12.w),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_outlined, color: Colors.black54, size: 18.sp),
          ],
        ),
      ),
    );
  }
}

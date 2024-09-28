import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10.h),
              // Back Button
              Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, size: 24.sp, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Spacer(),  // Add spacer to move the name to the center
                  Text(
                    "Ramesh Prajapati",  // Replace with user's name
                    style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w600),
                  ),
                  Spacer(),  // Add spacer to balance layout
                ],
              ),
              // Profile Section
              SizedBox(height: 20.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36.r,
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                      child: CircleAvatar(
                        radius: 33.r,
                        backgroundImage: NetworkImage('https://your_image_link.com'), // Replace with user's profile picture
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              "AJ-6",
                              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.red),
                            ),
                            SizedBox(height: 3.h),
                            Text("Your Rank", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black54)),
                          ],
                        ),
                        SizedBox(width: 25.w),
                        Column(
                          children: [

                            Text(
                              "71.2k",
                              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                            SizedBox(height: 3.h),
                            Text("Total Team", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black54)),
                          ],
                        ),
                        SizedBox(width: 25.w),
                        Column(
                          children: [
                            Text(
                              "2,552",
                              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                            SizedBox(height: 3.h),
                            Text("Direct Joins", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Rank, Team, Joins


              SizedBox(height: 20.h),
              // Wallet Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWalletBox("₹ 10,000", "Current Wallet", Colors.red),
                  _buildWalletBox("₹ 2,500", "Bonus Wallet", Colors.red),
                ],
              ),
              SizedBox(height: 20.h),

              // Menu Options
              _buildMenuOption(Icons.person, "My Profile"),
              _buildMenuOption(Icons.picture_as_pdf, "Plan PDF"),
              _buildMenuOption(Icons.account_balance_outlined, "KYC Details"),
              _buildMenuOption(Icons.receipt_long_rounded, "Transaction Report"),
              _buildMenuOption(Icons.receipt_long_rounded, "Income Report"),
              _buildMenuOption(Icons.lock, "Change Password"),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build Wallet Box
  Widget _buildWalletBox(String amount, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 19.h, horizontal: 30.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Function to build Menu Option
  Widget _buildMenuOption(IconData icon, String label) {
    return InkWell(
      onTap: () {
        // Handle navigation
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
            Icon(icon, color: Colors.red, size: 22.sp),
            SizedBox(width: 12.w),
            Text(
              label,
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

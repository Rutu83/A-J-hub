import 'package:ajhub_app/network/rest_apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORTANT: Replace 'package_name' with your actual package name if needed for other imports.
// For this self-contained file, it's not strictly necessary.

class WorkWithUS extends StatefulWidget {
  const WorkWithUS({super.key});

  @override
  State<WorkWithUS> createState() => _WorkWithUSState();
}

class _WorkWithUSState extends State<WorkWithUS> {
  bool _isLoading = false;
  // --- API & State Management Logic ---

  /// IMPORTANT: Replace this with your actual auth token retrieval logic.
  /// This function should fetch the token you saved after the user logged in.
  /// It might come from SharedPreferences, FlutterSecureStorage, or a state manager.
  Future<void> _submitInquiry(String franchiseType) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Call the refactored service method, providing callbacks for UI updates.
    await submitFranchiseInquiry(
      franchiseType: franchiseType,
      onSuccess: (String message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green.shade700,
          ),
        );
      },
      onFail: (String message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade700,
          ),
        );
      },
    );

    // The loading state is now set within the callbacks to ensure it
    // always reflects the correct status.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Shows a modal bottom sheet for the user to select a franchise type.
  void _showFranchiseSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Franchise Type",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              _buildSelectionTile(
                icon: Icons.flag_circle,
                title: "State Franchise",
                onTap: () {
                  Navigator.pop(context); // Close the sheet
                  _submitInquiry('state'); // Call API
                },
              ),
              _buildSelectionTile(
                icon: Icons.map,
                title: "Zone Franchise",
                onTap: () {
                  Navigator.pop(context);
                  _submitInquiry('zone');
                },
              ),
              _buildSelectionTile(
                icon: Icons.location_city,
                title: "District Franchise",
                onTap: () {
                  Navigator.pop(context);
                  _submitInquiry('district');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper widget for the options in the bottom sheet.
  Widget _buildSelectionTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.red.shade700, size: 26.sp),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, fontSize: 15.sp)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define reusable text styles for consistency
    final titleStyle = GoogleFonts.poppins(
      fontSize: 22.sp,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
    final subtitleStyle = GoogleFonts.poppins(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: Colors.red.shade800,
    );
    final bodyStyle = GoogleFonts.poppins(
      fontSize: 14.sp,
      color: Colors.black54,
      height: 1.6, // Improves readability
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Partner with Us",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Section ---
              Text(
                "Unlock Your Entrepreneurial Potential",
                style: titleStyle,
              ),
              SizedBox(height: 8.h),
              Text(
                "Are you ready to embark on a rewarding entrepreneurial journey? Join our growing family of successful franchisees and become a part of a proven business model.",
                style: bodyStyle,
              ),
              SizedBox(height: 24.h),

              // --- "Why Choose Us" Section ---
              _buildSectionTitle("Why Choose Our Franchise?", subtitleStyle),
              Text(
                "At AJ Hub, we offer more than just a business opportunity; we offer a partnership built on support, innovation, and shared success.",
                style: bodyStyle,
              ),
              SizedBox(height: 16.h),
              _buildBenefitItem("Proven Business Model"),
              _buildBenefitItem("Comprehensive Training"),
              _buildBenefitItem("Ongoing Support"),
              _buildBenefitItem("Marketing & Branding Assets"),
              _buildBenefitItem("Proprietary Technology/Tools"),
              _buildBenefitItem("Strong Brand Recognition"),
              _buildBenefitItem("Collaborative Network"),
              SizedBox(height: 24.h),

              // --- Franchise Models Section ---
              _buildSectionTitle(
                  "Understanding Our Franchise Models", subtitleStyle),
              SizedBox(height: 8.h),

              _FranchiseCard(
                icon: Icons.flag_circle,
                title: "1. State Franchise",
                description:
                    "Grants you exclusive rights across an entire Indian state. Ideal for experienced entrepreneurs or large investment firms looking to establish a dominant presence.",
                benefits: const [
                  "Maximum Market Penetration",
                  "Significant Revenue Potential",
                  "Master Franchisee Role",
                  "Strategic Control",
                  "High Growth Prospects",
                ],
              ),
              SizedBox(height: 12.h),
              _FranchiseCard(
                icon: Icons.map,
                title: "2. Zone Franchise",
                description:
                    "Provides exclusive rights within a defined zone (e.g., a cluster of districts or a large metro area). Perfect for those seeking a substantial market presence.",
                benefits: const [
                  "Focused Market Dominance",
                  "Manageable Scale",
                  "High Customer Concentration",
                  "Direct Local Impact",
                  "Strong Return on Investment",
                ],
              ),
              SizedBox(height: 12.h),
              _FranchiseCard(
                icon: Icons.location_city,
                title: "3. District Franchise",
                description:
                    "Offers exclusive rights within a single administrative district. An excellent and accessible entry point for individual entrepreneurs.",
                benefits: const [
                  "Lower Initial Investment",
                  "Local Market Expertise",
                  "Direct Customer Engagement",
                  "Manageable Operations",
                  "Stepping Stone to Growth",
                ],
              ),
              SizedBox(height: 30.h),

              // --- Call to Action Section ---
              Center(
                child: Text(
                  "Ready to Take the Next Step?",
                  style: subtitleStyle,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "If you're an ambitious individual or organization looking to invest in a thriving business, we want to hear from you! We are committed to empowering our franchisees and helping them achieve their entrepreneurial dreams.",
                style: bodyStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Center(
                // Show a loading indicator or the button based on the _isLoading state
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.red)
                    : ElevatedButton.icon(
                        onPressed: _showFranchiseSelectionSheet,
                        icon: const Icon(Icons.edit_note, color: Colors.white),
                        label: Text("Fill out our Franchise Inquiry Form",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                      ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for section titles
  Widget _buildSectionTitle(String title, TextStyle style) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(title, style: style),
    );
  }

  // Helper widget for benefit list items
  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A custom widget for the expandable franchise cards (No changes needed here)
class _FranchiseCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> benefits;

  const _FranchiseCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.benefits,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.red.shade700, size: 28.sp),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        childrenPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          Divider(height: 24.h, thickness: 1),
          Text(
            "Benefits:",
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10.h),
          ...benefits
              .map((benefit) => _buildCardBenefitItem(benefit, context))
              .toList(),
        ],
      ),
    );
  }

  // Specific benefit item for inside the card
  Widget _buildCardBenefitItem(String text, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_forward_ios,
              color: Colors.red.shade400, size: 14.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

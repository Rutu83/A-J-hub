import 'package:allinone_app/screens/team_member_list.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BusinessScreen extends StatelessWidget {
  const BusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "My Business",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Changed to black for visibility
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildIncomeRow(),
              const SizedBox(height: 10),
              _buildBenefitsAnalysis(),
              const SizedBox(height: 15),
              _buildLoginButton(context),
              const SizedBox(height: 15),
              _buildTeamMembersInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildIncomeContainer('Total User Income', 'OUSDT'),
        _buildIncomeContainer('Total Income', 'OUSDT'),
      ],
    );
  }

  Widget _buildIncomeContainer(String title, String subtitle) {
    return Container(
      height: 100,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.11),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.money),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: GoogleFonts.aBeeZee(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBenefitsAnalysis() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.11),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Benefits Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: SizedBox(
              height: 250,
              width: 300,
              child: PieChart(
                PieChartData(
                  sections: [
                    _buildPieChartSection('Rating Income', Colors.red, 30),
                    _buildPieChartSection('Team Income', Colors.blueAccent, 40),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildLegendRow(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieChartSection(
      String title, Color color, double value) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      radius: 50,
      titleStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildLegendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Rating Income', Colors.red),
        _buildLegendItem('Team Income', Colors.blueAccent),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 10,
              width: 15,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: GoogleFonts.aBeeZee(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 23),
          child: Text(
            '0',
            style: GoogleFonts.poppins(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TeamMemberList()),
        );
      },
      child: Container(
        //margin: const EdgeInsets.symmetric(horizontal: 30.0),
        alignment: Alignment.center,
        width: double.infinity,
        height: 55.0,
        decoration: BoxDecoration(
          borderRadius:  BorderRadius.circular(8),
          color: Colors.red
          // gradient: LinearGradient(
          //   colors: [
          //     Colors.red[200]!,
          //     Colors.red[900]!,
          //   ],
          // ),
          // boxShadow: [
          //   BoxShadow(
          //     offset: const Offset(0, 0),
          //     color: Colors.red[100]!,
          //     blurRadius: 16.0,
          //   ),
          //   BoxShadow(
          //     offset: const Offset(0, 0),
          //     color: Colors.red[200]!,
          //     blurRadius: 16.0,
          //   ),
          //   BoxShadow(
          //     offset: const Offset(0, 0),
          //     color: Colors.red[300]!,
          //     blurRadius: 16.0,
          //   ),
          // ],
        ),
        child: const Text(
          "Team Member List",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMembersInfo() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.11),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Total Team members 0',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          _buildTeamMembersStats(),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Divider(),
          ),
        ],
      ),
    );
  }


  Widget _buildTeamMembersStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('0', 'Today added'),
        _buildStatItem('0', 'Last week added'),
        _buildStatItem('0', 'This Month added'),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.aBeeZee(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

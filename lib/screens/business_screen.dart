// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'dart:convert'; // Required for JSON parsing
import 'package:allinone_app/main.dart';
import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; // HTTP package
import 'package:allinone_app/screens/team_member_list.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  _BusinessScreenState createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  Map<String, dynamic>? businessData;

  Future<void> fetchBusinessData() async {
    const String url = 'https://ajhub.co.in/api/business-data';
    final String token = appStore.token; // Ensure this is your actual token

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': "Bearer $token",
        },
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('Response headers: ${response.headers}');
      }

      if (response.statusCode == 200 && response.headers['content-type'] == 'application/json') {
        setState(() {
          businessData = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load business data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBusinessData();
  }

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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: businessData == null
          ? _buildSkeletonLoader()
          : SingleChildScrollView(
             child: Padding(

               padding: const EdgeInsets.only(left: 16.0,right: 16.0,top: 10.0,bottom: 100),
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
  Widget _buildBenefitsAnalysis() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: const Offset(0, 3), // Offset in x and y direction
          ),
        ],
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
                    _buildPieChartSection('30.0%', Colors.red, 30),
                    _buildPieChartSection('40.0%', Colors.blueAccent, 40),
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
        color: Colors.white,
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
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (businessData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamMemberList(userData: businessData!['user']),
            ),
          );
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 55.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.red,
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


  Widget _buildIncomeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildIncomeContainer('Direct Income', businessData?['directIncome'] ?? '0 OUSDT'),
        _buildIncomeContainer('Total Income', businessData?['totalIncome'].toString() ?? '0 OUSDT'),
      ],
    );
  }

  Widget _buildIncomeContainer(String title, String income) {
    return Container(
      height: 90,
      width: 170.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: const Offset(0, 3), // Offset in x and y direction
          ),
        ],
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
            income,
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

  Widget _buildTeamMembersInfo() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: const Offset(0, 3), // Offset in x and y direction
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Total Team members ${businessData ?? '0'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          _buildTeamMembersStats(),
          const SizedBox(height: 15),
        ],
      ),
    );

  }

  Widget _buildTeamMembersStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(height: 10,width: 10,),
        Expanded(
          child: _buildStatItem(businessData?['todayTotalTeam'].toString() ?? '0', 'Today\n Join'),
        ),
        const SizedBox(height: 10,width: 10,),
        Expanded(
          child: _buildStatItem(businessData?['lastWeekTotalTeam'].toString() ?? '0', 'Direct Circle'),
        ),
        const SizedBox(height: 10,width: 10,),
        Expanded(
          child: _buildStatItem(businessData?['thisMonthTotalTeam'].toString() ?? '0', 'Total Circle'),
        ),
        const SizedBox(height: 10,width: 10,),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Container(

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: const Offset(0, 3), // Offset in x and y direction
          ),
        ],
      ),
      padding: const EdgeInsets.all(26.0),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildShimmerBox(height: 100, width: double.infinity), // Skeleton for income row
          const SizedBox(height: 10),
          _buildShimmerBox(height: 250, width: double.infinity), // Skeleton for pie chart
          const SizedBox(height: 15),
          _buildShimmerBox(height: 55, width: double.infinity), // Skeleton for login button
          const SizedBox(height: 15),
          _buildShimmerBox(height: 200, width: double.infinity), // Skeleton for team member info
        ],
      ),
    );
  }

  Widget _buildShimmerBox({required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

}


// ignore_for_file: library_private_types_in_public_api

import 'package:allinone_app/model/business_mode.dart';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:allinone_app/screens/team_member_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:allinone_app/utils/shimmer/shimmer.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  _BusinessScreenState createState() => _BusinessScreenState();
}
class _BusinessScreenState extends State<BusinessScreen> {
  Future<List<BusinessModal>>? futureBusiness;
  BusinessModal? businessData;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    futureBusiness = fetchBusinessData();
  }

  Future<List<BusinessModal>> fetchBusinessData() async {
    try {
      final data = await getBusinessData(businessmodal: []);
      if (data.isNotEmpty) {
        businessData = data.first; // Store the first item
      }
      return data;
    } catch (e) {
      throw Exception('Failed to load business data: $e');
    }
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
      body: FutureBuilder<List<BusinessModal>>(
        future: futureBusiness,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonLoader();
          } else if (snapshot.hasError) {
            if (kDebugMode) {
              print(snapshot.error);
            }
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(child: Text('No business data available.'));
            }
            // Existing logic for building UI with snapshot.data
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 100),
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
            );
          }
          return Container();
        },
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
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Total Circle Member: ${businessData?.business?.totalTeamCount ?? '0'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          Padding(padding: const EdgeInsets.only(left: 5,right: 5),
          child:   _buildTeamMembersStats() ,
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildTeamMembersStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildStatItem(businessData?.business?.directTeamCount.toString() ?? '0', 'Direct Circle'),
        ),
        const SizedBox(width: 10,),
        Expanded(
          child: _buildStatItem(businessData?.business?.totalTeamCount.toString() ?? '0', 'Total Circle'),
        ),
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
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
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

  Widget _buildLoginButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (businessData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamMemberList(userData: businessData!.business?.levelDownline),
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
        _buildIncomeContainer("1st Circle Income", businessData?.business?.sponserIncome.toString() ?? '0'),
        _buildIncomeContainer('Total Income', businessData?.business?.totalIncome.toString() ?? '0'),
      ],
    );
  }

  Widget _buildIncomeContainer(String title, String income) {
    return Container(
      height: 90,
      width: 160.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
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
            '₹ $income',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
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
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
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

  PieChartSectionData _buildPieChartSection(String title, Color color, double value) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLegendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(Colors.red, 'Legend 1'),
        _buildLegendItem(Colors.blueAccent, 'Legend 2'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String title) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(title),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer(
          gradient: const LinearGradient(
            colors: [
              Colors.grey,
              Colors.white,
              Colors.grey,
            ],
            stops: [0.1, 0.5, 0.9],
          ),
          child: Container(
            height: 100,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}

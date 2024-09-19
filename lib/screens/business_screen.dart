// ignore_for_file: depend_on_referenced_packages

import 'dart:convert'; // Required for JSON parsing
import 'package:allinone_app/main.dart';
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

  // Future<void> fetchBusinessData() async {
  //   final String url = 'https://ajhub.co.in/api/business-data';
  //   final String token = appStore.token; // Replace with your actual token
  //
  //   try {
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Authorization': "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5ZDA2MGQ1Mi0yNDNlLTRhZWQtYmI1NC1hMjNkYmI2YTQ1YTEiLCJqdGkiOiJkZjgyYzUyYTVkZWU1OGU4ZmU4YTY5MzY5OWY4NmQzZWFjNDJiOTIyNTBhODE1MzcyZTZjNDBjNTdiNmQwNDEwZjhlNmQ1YjQ4ZjRkMjhlNyIsImlhdCI6MTcyNjcyMzM3Ni42NDg4ODgsIm5iZiI6MTcyNjcyMzM3Ni42NDg4OTIsImV4cCI6MTc0MjM2MTc3Ni42NDczNjQsInN1YiI6IjE5NSIsInNjb3BlcyI6W119.grqTTgxRszPAyTjCsLGn1GBJPPyeKnldXQAsu-v5roLIQcTXxRMOKA_Fug2aoCQk6kJ_SSwk7ZJ8JgT5Q2pPKeZ_D7ss59ondT6o9Z2OGn5ckLFDjoMIdHIMCSU7K8M1F70cy3BAHqawXWuiIMyZvkNqLRH8NTW5usoGgy2473s1306R2kuSjNVc9eU6TUNFa3baBfmwDYGAEP3AhMdc68AjSN2OhGWyqkjDge-IIeV6KJfhf4-6Rk3MX8vRsOiAj153hgnwR2_aCTVqeIt4JTDL403dcQN18GWqdONzaMA-QGtA4kvSaz0gnBSuG7o2r80wMf6qUxpJqys14FJ5uB84rVzY1bqU77mKfaeUuCRCa2QJYr5WBv6mF1zD8tCR2dTnGeqKs8ibmiHVMXELga1v3b2MD5xmLrFjXKDestcwIYz44FZCl6wL4MJCWmHlSLNzh0IDkn-oZQXMDgoqRwNzYdjUWFdZl93Jvn8lFZIeDczd1BHRq145qMTKPU4sufCp2ZanMvsrzGnnTY5tGnUx5sBND8oNJ3CuI0nui-6p7Ybatjou817gtMqFYwFEi9okVcXEpckY",
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         businessData = json.decode(response.body);
  //       });
  //     } else {
  //       throw Exception('Failed to load business data');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }
  //
  //
  //




  Future<void> fetchBusinessData() async {
    final String url = 'https://ajhub.co.in/api/business-data';
    final String token = appStore.token; // Ensure this is your actual token


    print('oooooo $token');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': "Bearer $token"},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200 && response.headers['content-type'] == 'application/json') {
        setState(() {
          businessData = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load business data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
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

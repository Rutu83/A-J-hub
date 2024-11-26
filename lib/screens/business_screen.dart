// ignore_for_file: library_private_types_in_public_api

import 'package:allinone_app/model/business_mode.dart';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:allinone_app/screens/team_member_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:allinone_app/utils/shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

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
        if (kDebugMode) {
          print(data);
        }

      }
      return data;
    } catch (e) {
      throw Exception('Failed to load business data: $e');
    }
  }

  final List<Map<String, String>> businessData2 = [
    {
      'Income Type': '1st Circle Income',
      'Amount': '₹5000',
      'Amount2': '₹5000',
      'Amount3': '₹5000',
    },
    {
      'Income Type': 'Total Income',
      'Amount': '₹15000',
      'Amount2': '₹15000',
      'Amount3': '₹15000',
    },
    {
      'Income Type': 'Direct Circle',
      'Amount': '₹2000',
      'Amount2': '₹2000',
      'Amount3': '₹2000',
    },
    {
      'Income Type': 'Total Circle',
      'Amount': '₹8000',
      'Amount2': '₹8000',
      'Amount3': '₹8000',
    },


  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
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
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildIncomeRow(),
                    const SizedBox(height: 10),
                    _buildBenefitsAnalysis(),
                    const SizedBox(height: 15),
                    _buildButton(context),
                    const SizedBox(height: 15),
                    _buildTable(context),




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

  Widget _buildTable(BuildContext context) {
    // Updated business data with more details like 'Date' and 'Status'
    final List<Map<String, String>> businessData2 = [
      {
        'Income Type': 'Total Income',
        'Amount': '₹15000',
        'Date': '2024-01-15',
        'Status': 'Completed',
      },
      {
        'Income Type': 'Total Circle',
        'Amount': '₹8000',
        'Date': '2024-02-10',
        'Status': 'In Progress',
      },
      {
        'Income Type': '1st Circle Income',
        'Amount': '₹5000',
        'Date': '2024-01-20',
        'Status': 'Completed',
      },
      {
        'Income Type': 'Direct Circle',
        'Amount': '₹2000',
        'Date': '2024-03-05',
        'Status': 'Pending',
      },
    ];

    return Container(
      margin: const EdgeInsets.only(left: 16,right: 16,top: 16), // Added margin around the container for spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align title to the left
        children: [
          // Title for the table
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0), // Space between title and table
            child: Text(
              'Business Income Report',  // Title text
              style: TextStyle(
                fontSize: 20,  // Larger font size for the title
                fontWeight: FontWeight.bold, // Bold font
                color: Colors.black,  // Black color for the title
              ),
            ),
          ),

          // Table inside a SingleChildScrollView for horizontal scrolling
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Allow horizontal scroll for wide tables
            child: DataTable(
              headingRowHeight: 48, // Reduced height for header row
              dataRowHeight: 48, // Reduced height for data rows
              border: TableBorder.all(  // Add borders to all cells
                color: Colors.black,    // Border color
                width: 1,               // Border width
                borderRadius: BorderRadius.zero,  // Optional: set if you need rounded corners
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'Income Type',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue), // Custom font size and color
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue), // Custom font size and color
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue), // Custom font size and color
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue), // Custom font size and color
                  ),
                ),
              ],
              rows: businessData2.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> data = entry.value;

                // Set row color based on index or any condition
                Color rowColor = index.isEven ? Colors.grey[100]! : Colors.white;

                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    return rowColor; // Set alternating row colors
                  }),
                  cells: [
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Reduced padding for compact view
                        child: Text(data['Income Type'] ?? '', style: TextStyle(fontSize: 12)), // Reduced font size
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Reduced padding for compact view
                        child: Text(data['Amount'] ?? '', style: TextStyle(fontSize: 12)), // Reduced font size
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Reduced padding for compact view
                        child: Text(data['Date'] ?? '', style: TextStyle(fontSize: 12)), // Reduced font size
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Reduced padding for compact view
                        child: Text(data['Status'] ?? '', style: TextStyle(fontSize: 12)), // Reduced font size
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildButton(BuildContext context) {
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIncomeContainer("1st Circle Income", businessData?.business?.sponserIncome.toString() ?? '0', Icons.account_balance_wallet),
            _buildIncomeContainer('Total Income', businessData?.business?.totalIncome.toString() ?? '0', Icons.attach_money),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIncomeContainer('Direct Circle', businessData?.business?.directTeamCount.toString() ?? '0', Icons.people),
            _buildIncomeContainer('Total Circle', businessData?.business?.totalTeamCount.toString() ?? '0', Icons.group),
          ],
        ),
      ],
    );
  }

  Widget _buildIncomeContainer(String title, String income, IconData icon) {
    return Container(
      height: 100,
      width: 160.w,
      decoration: BoxDecoration(
        color: Colors.white,  // Background color
        borderRadius: BorderRadius.circular(12),  // Rounded corners
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 2))  // Subtle shadow for depth
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 30,  // Icon size
            ),
           // const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
           // const SizedBox(height: 8),
            Text(
              '₹$income',
              style: GoogleFonts.adamina(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18, // Adjust font size for better visibility
              ),
            ),
          ],
        ),
      ),
    );
  }





  Widget _buildBenefitsAnalysis() {
    double totalValue = (businessData?.business?.totle_user ?? 1).toDouble(); // Convert to double
    double redValue = (businessData?.business?.totle_user ?? 0).toDouble(); // Convert to double
    double blueValue = (businessData?.business?.totalTeamCount ?? 0).toDouble(); // Convert to double

    // Calculate percentages for each section (as fraction of the total value)
    double redPercentage = (redValue / totalValue) * 100;
    double bluePercentage = (blueValue / totalValue) * 100;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3), // Shadow effect applied to the container
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
                    _buildPieChartSection('Total Users', Colors.red, redValue.toInt(), context),
                    _buildPieChartSection('Team Count', Colors.blue, blueValue.toInt(), context),
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

  PieChartSectionData _buildPieChartSection(String title, Color color, int value, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 350 ? 18 : 25; // Adjust font size for smaller screens
    double radius = screenWidth < 350 ? 70 : 80; // Adjust radius for smaller screens

    // Using a border color to make the section stand out
    return PieChartSectionData(
      color: color,
      title: '$value', // Display original integer value inside the section
      titleStyle: GoogleFonts.adamina(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: fontSize, // Dynamically adjusted font size
      ),
      value: value.toDouble(), // Convert the value back to double for the pie chart
      radius: radius, // Dynamically adjusted radius
      showTitle: true, // Ensure title is shown inside each pie section
      borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1), // Add a white border to each pie section
      titlePositionPercentageOffset: 0.55, // Adjust the title's position inside the pie section
    );
  }


  Widget _buildLegendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(Colors.red, 'Total Users'),
        _buildLegendItem(Colors.blue, 'Team Count'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label),
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

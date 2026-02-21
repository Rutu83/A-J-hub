// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'package:ajhub_app/model/business_mode.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  _BusinessScreenState createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  Future<List<BusinessModal>>? futureBusiness;
  String referralCode = "Loading...";
  bool isMembershipActive = false;
  bool hasError = false;
  String errorMessage = '';
  BusinessModal? businessData;
  List<bool> isExpanded = List.generate(rewards.length, (_) => false);
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
      setState(() {
        hasError = false;
        errorMessage = "";
      });

      final data = await getBusinessData(businessmodal: []);

      if (data.isNotEmpty) {
        setState(() {
          businessData = data.first; // Store the first item
        });

        if (kDebugMode) {
          print("Business data fetched successfully.");
        }
      }

      setState(() {});

      return data;
    } on SocketException catch (_) {
      setState(() {
        hasError = true;
        errorMessage = "No internet connection. Please check your network.";
      });
      return []; // Return an empty list on failure
    } on HttpException catch (_) {
      setState(() {
        hasError = true;
        errorMessage = "Couldn't connect to the server. Try again later.";
      });
      return [];
    } on TimeoutException catch (_) {
      setState(() {
        hasError = true;
        errorMessage = "Network timeout. Please try again.";
      });
      return [];
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = "An unexpected error occurred: $e";
      });

      if (kDebugMode) {
        print("Error fetching business data: $e");
      }
      return [];
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
    if (hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20), // Add padding to the sides
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Network Error Animation with border
                AnimatedOpacity(
                  opacity: hasError ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: 300, // Adjust the width for better responsiveness
                    height: 300, // Adjust the height for better responsiveness
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Colors.red, // Border color
                    //     width: 3, // Border width
                    //   ),
                    //   borderRadius: BorderRadius.circular(12), // Rounded corners
                    // ),
                    child: Lottie.asset(
                      'assets/animation/no_internet_2_lottie.json',
                      width: 350,
                      height: 350,
                    ),
                  ),
                ),

                const SizedBox(height: 30), // Increase spacing

                // Title Text
                const Text(
                  'Oops! Something went wrong.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .black87, // Slightly darkened text for better contrast
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle Text
                const Text(
                  'Please check your connection and try again.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center, // Center align the text
                ),

                const SizedBox(
                    height: 30), // Increased space between text and button

                // Retry Button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      hasError = false;
                    });
                    futureBusiness = fetchBusinessData();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text("Retry",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    textStyle: const TextStyle(
                      fontSize:
                          18, // Slightly larger font size for better readability
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "My Business",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black, // Set text color to white
          ),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200.h,
                    width: 300.w,
                    child: Lottie.asset('assets/animation/error_lottie.json'),
                  ),
                  Text(
                    'No Business data found.',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(child: Text('No business data available.'));
            }
            // Existing logic for building UI with snapshot.data
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 10.0, bottom: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildIncomeRow(),
                    const SizedBox(height: 10),
                    // _buildBenefitsAnalysis(),
                    const SizedBox(height: 15),
                    // _buildButton(context),
                    // const SizedBox(height: 15),

                    buildCenteredRewardTitle('Reward', Icons.star),

                    ListView.builder(
                      shrinkWrap: true, // Prevent unbounded height
                      physics:
                          const NeverScrollableScrollPhysics(), // Prevent nested scroll conflict
                      padding: const EdgeInsets.all(6.0),
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            // Vertical Line
                            Positioned(
                              left: 25,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 2,
                                color:
                                    Colors.grey.shade300, // Default Grey line
                              ),
                            ),
                            // Highlighted Vertical Line
                            Positioned(
                              left: 25,
                              top: 0,
                              height: rewards[index].isCompleted ? 200 : 0,
                              child: Container(
                                width: 2,
                                color: rewards[index].isCompleted
                                    ? Colors.green
                                    : Colors.grey.shade300,
                              ),
                            ),
                            // Horizontal Line
                            Positioned(
                              left: 25,
                              top: 25,
                              width: rewards[index].isCompleted ? 100 : 100,
                              height: 1,
                              child: Container(
                                color: rewards[index].isCompleted
                                    ? Colors.green
                                    : Colors.grey.shade300,
                              ),
                            ),

                            // Level Card
                            buildLevelCard(context, rewards[index], index),
                          ],
                        );
                      },
                    ),
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

  Widget buildCenteredRewardTitle(String title, IconData icon) {
    return Align(
      alignment:
          Alignment.centerLeft, // Align to center-left or adjust to right
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Shrink to fit content
          children: [
            Icon(
              icon,
              size: 28, // Icon size
              color: Colors.red, // Icon color
            ),
            const SizedBox(width: 8), // Space between icon and text
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 26, // Font size
                fontWeight: FontWeight.w500, // Medium weight
                color: Colors.black87, // Text color
              ),
              textAlign:
                  TextAlign.center, // Center align text within the container
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLevelCard(BuildContext context, RewardLevel reward, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 2),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(222),
            boxShadow: reward.isCompleted
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: reward.isCompleted
                ? Colors.green.shade100
                : Colors.grey.shade200,
            child: Icon(
              reward.icon,
              color: reward.isCompleted ? Colors.green : Colors.grey,
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          reward.levelName,
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Icon(
                          reward.isCompleted
                              ? Icons.check_circle
                              : Icons.pending,
                          color: reward.isCompleted ? Colors.green : Colors.red,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward.points,
                      style: GoogleFonts.openSans(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    if (reward.benefits.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded[index] = !isExpanded[index];
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Benefits",
                              style: GoogleFonts.lato(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Icon(
                              isExpanded[index]
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                      if (isExpanded[index])
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: reward.benefits
                              .map((benefit) => Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      "- $benefit",
                                      style: GoogleFonts.openSans(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildButton(BuildContext context) {
  //   return InkWell(
  //     onTap: () {
  //       if (businessData != null) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => TeamMemberList(userData: businessData!.business?.levelDownline),
  //           ),
  //         );
  //       }
  //     },
  //     child: Container(
  //       alignment: Alignment.center,
  //       width: double.infinity,
  //       height: 55.0,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(8),
  //         color: Colors.red,
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Icon(
  //             CupertinoIcons.person_2_fill,  // Cupertino icon for team members
  //             color: Colors.white,
  //             size: 24.0,  // Adjust icon size as needed
  //           ),
  //           const SizedBox(width: 8.0),  // Space between icon and text
  //           Text(
  //             "Team Member List",
  //             style: GoogleFonts.roboto(  // Apply Google Font (Roboto)
  //               color: Colors.white,
  //               fontWeight: FontWeight.w900,
  //               fontSize: 18.0,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildIncomeRow() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIncomeContainer(
              "Referral Income",
              businessData?.business?.sponserIncome.toString() ?? '0',
              Icons.account_balance_wallet,
            ),
            _buildIncomeContainer(
              'Refer User',
              businessData?.business?.directTeamCount.toString() ?? '0',
              CupertinoIcons.person_2_square_stack,
            ),
          ],
        ),
        // const SizedBox(height: 16.0), // More spacing for better layout
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     _buildIncomeContainer(
        //       'Direct Circle',
        //       businessData?.business?.directTeamCount.toString() ?? '0',
        //       Icons.people,
        //     ),
        //     _buildIncomeContainer(
        //       'Total Circle',
        //       businessData?.business?.totalTeamCount.toString() ?? '0',
        //       Icons.group,
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildIncomeContainer(String title, String income, IconData icon) {
    return Expanded(
      child: Container(
        height: 120.h,
        margin: const EdgeInsets.symmetric(
            horizontal: 8.0), // Space between containers
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Smooth rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Subtle shadow
              blurRadius: 8,
              offset: const Offset(0, 4), // Shadow offset
            ),
          ],
          border: Border.all(
              color: Colors.grey.shade300, width: 1.5), // Soft border
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50, // Light background for the icon
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.blue.shade600,
                  size: 28, // Icon size
                ),
              ),
              const SizedBox(height: 12.0), // Space between icon and title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (title == "Refer User")
                Text(
                  income,
                  style: GoogleFonts.poppins(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp, // Larger font for emphasis
                  ),
                ),

              if (title != "Refer User")
                Text(
                  '₹$income',
                  style: GoogleFonts.poppins(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp, // Larger font for emphasis
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //  Widget _buildBenefitsAnalysis() {
  // //   double totalValue = (businessData?.business?.totle_user ?? 1).toDouble(); // Convert to double
  //    double redValue = (businessData?.business?.totleUser ?? 0).toDouble(); // Convert to double
  //    double blueValue = (businessData?.business?.totalTeamCount ?? 0).toDouble(); // Convert to double
  //
  //    // Calculate percentages for each section (as fraction of the total value)
  //
  //    return Container(
  //      width: double.infinity,
  //      decoration: BoxDecoration(
  //        color: Colors.white,
  //        borderRadius: BorderRadius.circular(12),
  //        boxShadow: [
  //          BoxShadow(
  //            color: Colors.grey.withOpacity(0.5),
  //            spreadRadius: 3,
  //            blurRadius: 5,
  //            offset: const Offset(0, 3), // Shadow effect applied to the container
  //          ),
  //        ],
  //      ),
  //      child: Column(
  //        crossAxisAlignment: CrossAxisAlignment.start,
  //        children: [
  //          const Padding(
  //            padding: EdgeInsets.all(8.0),
  //            child: Text(
  //              'Team Analysis',
  //              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //            ),
  //          ),
  //          Center(
  //            child: SizedBox(
  //              height: 250,
  //              width: 300,
  //              child: PieChart(
  //                PieChartData(
  //                  sections: [
  //                    _buildPieChartSection('Total Team', Colors.red, redValue.toInt(), context),
  //                    _buildPieChartSection('Active Team', Colors.blue, blueValue.toInt(), context),
  //                  ],
  //                  centerSpaceRadius: 40,
  //                  sectionsSpace: 2,
  //                ),
  //              ),
  //            ),
  //          ),
  //          const SizedBox(height: 10),
  //          _buildLegendRow(),
  //          const SizedBox(height: 30),
  //        ],
  //      ),
  //    );
  //  }

  // PieChartSectionData _buildPieChartSection(String title, Color color, int value, BuildContext context) {
  //   double screenWidth = MediaQuery.of(context).size.width;
  //   double fontSize = screenWidth < 350 ? 18 : 25; // Adjust font size for smaller screens
  //   double radius = screenWidth < 350 ? 70 : 80; // Adjust radius for smaller screens
  //
  //   // Using a border color to make the section stand out
  //   return PieChartSectionData(
  //     color: color,
  //     title: '$value', // Display original integer value inside the section
  //     titleStyle: GoogleFonts.adamina(
  //       color: Colors.white,
  //       fontWeight: FontWeight.bold,
  //       fontSize: fontSize, // Dynamically adjusted font size
  //     ),
  //     value: value.toDouble(), // Convert the value back to double for the pie chart
  //     radius: radius, // Dynamically adjusted radius
  //     showTitle: true, // Ensure title is shown inside each pie section
  //     borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1), // Add a white border to each pie section
  //     titlePositionPercentageOffset: 0.55, // Adjust the title's position inside the pie section
  //   );
  // }
  //
  // Widget _buildLegendRow() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       _buildLegendItem(Colors.red, 'Total Team'),
  //       _buildLegendItem(Colors.blue, 'Active Team'),
  //     ],
  //   );
  // }

  // Widget _buildLegendItem(Color color, String label) {
  //   return Row(
  //     children: [
  //       Container(
  //         width: 20,
  //         height: 20,
  //
  //         decoration: BoxDecoration(
  //             color: color,
  //           borderRadius: BorderRadius.circular(15)
  //         ),
  //       ),
  //       const SizedBox(width: 8),
  //       Text(label),
  //     ],
  //   );
  // }

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

class RewardLevel {
  final String levelName;
  final String points;
  final IconData icon;
  final bool isCompleted;
  final List<String> benefits;
  final String description; // New field for a brief description
  final String expiryDate; // New field for expiry date
  final double requiredSpending; // New field for required spending

  RewardLevel({
    required this.levelName,
    required this.points,
    required this.icon,
    required this.isCompleted,
    this.benefits = const [],
    this.description = '',
    this.expiryDate = 'No expiry',
    this.requiredSpending = 0.0,
  });
}

final List<RewardLevel> rewards = [
  RewardLevel(
    levelName: 'AJ CIRCLE - 1',
    points: '10 DIRECT REFERRAL',
    icon: Icons.star_border,
    isCompleted: false,
    benefits: ["GET YOUR DIGITAL ID", "SILVER PROGRAM ACCESS"],
  ),
  RewardLevel(
    levelName: "AJ CIRCLE - 2",
    points: '6 AJ 1 + 25 REFERRAL',
    icon: Icons.build_circle,
    isCompleted: false,
    benefits: ["UNLOCK THE GOLD PROGRAM", "AJ HUB T-SHIRT"],
  ),
  RewardLevel(
    levelName: "AJ CIRCLE - 3",
    points: '5 AJ 2 + 100 REFERRAL',
    icon: Icons.military_tech,
    isCompleted: false,
    benefits: [
      "GET A DOMESTIC TRIP",
      "(1 N /2 DAYS)",
    ],
  ),
  RewardLevel(
    levelName: "AJ CIRCLE - 4",
    points: '5 AJ 3 + 500 REFERRAL',
    icon: Icons.emoji_events,
    isCompleted: false,
    benefits: [
      "GET A GOA TRIP VOUCHER",
      "(2 NIGHTS / 3 DAYS)",
    ],
  ),
  RewardLevel(
    levelName: "AJ CIRCLE - 5",
    points: '4 AJ 4 + 1500 REFERRAL',
    icon: Icons.workspace_premium,
    isCompleted: false,
    benefits: [
      "EXPERIENCE A THAILAND",
      "TRIP (3 NIGHTS / 4 DAYS)",
    ],
  ),
  RewardLevel(
    levelName: "AJ CIRCLE - 6",
    points: '4 AJ 5 + 2500 REFERRAL',
    icon: Icons.diamond,
    isCompleted: false,
    benefits: [
      "WALK AWAY WITH",
      "50,000 /- CASH",
    ],
  ),
  RewardLevel(
    levelName: "AJ CIRCLE - 7",
    points: '3 AJ 6 + 5000 REFERRAL',
    icon: Icons.auto_awesome,
    isCompleted: false,
    benefits: [
      "WALK AWAY WITH",
      "1,00,000 /- CASH",
    ],
  ),
  RewardLevel(
    levelName: "AJ CIRCLE - 8",
    points: '3 AJ 7 + 10,000 REFERRAL',
    icon: Icons.add_a_photo_outlined,
    isCompleted: false,
    benefits: [
      "WALK AWAY WITH",
      "2,00,000 /- CASH",
    ],
  ),
  RewardLevel(
    levelName: "AJ CIRCLE - 9",
    points: '2 AJ 8 + 20,000 REFERRAL',
    icon: Icons.auto_awesome_mosaic,
    isCompleted: false,
    benefits: [
      "CLAIM A MASSIVE",
      "4,00,000 /- CASH",
    ],
  ),
  RewardLevel(
    levelName: "AJ CIRCLE - 10",
    points: '2 AJ 9 + 40,000 REFERRAL',
    icon: Icons.auto_awesome_motion,
    isCompleted: false,
    benefits: [
      "SECURE A WHOPPING",
      "8,00,000 /- CASH",
    ],
  ),
];

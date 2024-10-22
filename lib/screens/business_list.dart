// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/screens/edit_business_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'business_form.dart'; // Import the BusinessForm screen

class BusinessList extends StatefulWidget {
  const BusinessList({super.key});

  @override
  BusinessListState createState() => BusinessListState();
}

class BusinessListState extends State<BusinessList> {
  List<dynamic> businessData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBusinessData();
  }

  Future<void> fetchBusinessData() async {
    const apiUrl = 'https://ajhub.co.in/api/getbusinessprofile';
    String token = appStore.token; // Replace with your actual token

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          businessData = json.decode(response.body)['data'];
          isLoading = false;
        });
        if (kDebugMode) {
          print('Business data loaded successfully.');
        }
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching business data: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleErrorResponse(http.Response response) {
    if (kDebugMode) {
      print('Failed to load business data: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _deleteBusinessProfile(String id) async {
    final String apiUrl = 'https://ajhub.co.in/api/delete/business-profile/$id';
    String token = appStore.token; // Replace with your actual token

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Business profile with ID $id deleted successfully.');
        }
        // Reload business data after deletion
        fetchBusinessData();
      } else {
        _handleErrorResponse(response);
        if (kDebugMode) {
          print('Delete request failed with status: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting business profile: $e');
      }
    }
  }


  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Business'),
          content: const Text('Are you sure you want to delete this business?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteBusinessProfile(id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business List'),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : businessData.isEmpty
          ? _buildNoDataAvailable()
          : ListView.builder(
        itemCount: businessData.length,
        itemBuilder: (context, index) {
          final business = businessData[index];
          return BusinessCard(business: business, onDelete: () => _confirmDelete(business['id'].toString()));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BusinessForm()),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNoDataAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 60,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 10),
          Text(
            'No Business Data Available',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class BusinessCard extends StatelessWidget {
  final dynamic business;
  final VoidCallback onDelete;

  const BusinessCard({super.key, required this.business, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    String imageUrl = '${business['logo']}'.replaceAll(r'\/', '/');
    String businessId = business['id'].toString();  // Get the ID of the business

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 9,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.only(left: 16, right: 0, top: 16),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (business['logo'] != null && business['logo'].isNotEmpty)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          if (kDebugMode) {
                            print('Image load error: $error');
                            print('Attempted to load image from: $imageUrl');
                          }
                          return const Icon(Icons.image_not_supported);
                        },
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBusinessNameRow(business['business_name'] ?? 'Not Provided'),
                      _buildDetailRow(business['mobile_number'] ?? 'Not Provided', isGreen: true),
                      _buildDetailRow(business['state'] != null ? business['state']['name'] : 'Not Provided', isGreen: true),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Edit') {
                    if (kDebugMode) {
                      print('Edit option selected');
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBusinessForm(business: business), // Pass the selected business data
                      ),
                    );
                  } else if (value == 'Delete') {
                    if (kDebugMode) {
                      print('Delete option selected');
                    }
                    onDelete(); // Call the delete method when 'Delete' is selected
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'Edit', 'Delete'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessNameRow(String businessName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            businessName,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 5),
          Image.asset(
            'assets/icons/verified.png',
            width: 15,
            height: 15,
            fit: BoxFit.cover,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: isGreen ? Colors.grey : Colors.black,
        ),
      ),
    );
  }
}



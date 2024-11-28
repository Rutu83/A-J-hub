// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/screens/edit_business_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'business_form.dart'; // Import the BusinessForm screen

class BusinessList extends StatefulWidget {
  const BusinessList({super.key});

  @override
  BusinessListState createState() => BusinessListState();
}

class BusinessListState extends State<BusinessList> {
  List<dynamic> businessData = [];
  bool isLoading = true;
  int? selectedBusiness; // Nullable selected business ID

  @override
  void initState() {
    super.initState();
    fetchStoredBusinessID();
    fetchBusinessData();
  }

  // Fetch the stored business ID from SharedPreferences
  Future<void> fetchStoredBusinessID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedBusiness = prefs.getInt('selected_business_id'); // Load stored ID
    });
    if (kDebugMode) {
    //  print('Loaded stored business ID: $selectedBusiness');
    }
  }

  // Store the selected business ID in SharedPreferences
  Future<void> storeBusinessID(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selected_business_id', id); // Store the ID
    if (kDebugMode) {
     // print('Stored business ID: $id');
    }
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
        final data = json.decode(response.body)['data'];
        setState(() {
          businessData = data ?? [];
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
        businessData = [];
      });
    }
  }

  void _handleErrorResponse(http.Response response) {
    if (kDebugMode) {
   //   print('Failed to load business data: ${response.statusCode}');
   //   print('Response body: ${response.body}');
    }
    setState(() {
      isLoading = false;
    });
  }

  void _confirmDelete(String businessId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Business'),
          content: const Text('Are you sure you want to delete this business?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _deleteBusinessProfile(businessId); // Call delete function
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBusinessProfile(String businessId) async {
    setState(() {
      isLoading = true; // Show loader while deleting
    });

    final String apiUrl = 'https://ajhub.co.in/api/delete/business-profile/$businessId';
    String token = appStore.token; // Ensure token is correct

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Successfully deleted
        if (kDebugMode) {
          print('Business profile with ID $businessId deleted successfully.');
        }
        // Refresh the business list
        await fetchBusinessData();
        setState(() {}); // Ensure UI updates
      } else {
        _handleErrorResponse(response); // Handle response errors
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting business profile: $e');
      }
    } finally {
      setState(() {
        isLoading = false; // Hide loader
      });
    }
  }





  Future<void> updateBusinessStatus(int businessId) async {
    final String apiUrl = 'https://ajhub.co.in/api/status/business-profile/$businessId';
    String token = appStore.token; // Ensure token is not null

    if (token.isEmpty) {
      if (kDebugMode) {
        print('Error: Token is missing or invalid.');
      }
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Business status updated successfully for ID: $businessId');
        }
      } else {
        if (kDebugMode) {
          print('Error: ${response.statusCode}');
        }
        if (kDebugMode) {
          print('Response body: ${response.body}');
        }
        _handleErrorResponse(response); // Handle the error response
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating business status: $e');
      }
    }
  }

  // void _handleErrorResponse(http.Response response) {
  //   // Customize this function to handle specific error scenarios
  //   final decodedBody = jsonDecode(response.body);
  //   print('Error details: ${decodedBody['message']}'); // Adjust as per API response
  // }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business'),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator( color: Colors.red,))
          : Column(
        children: [
          Expanded(
            child: businessData.isEmpty
                ? _buildNoDataAvailable()
                : ListView.builder(
              itemCount: businessData.length,
              itemBuilder: (context, index) {
                final business = businessData[index];
                return BusinessCard(
                  business: business,
                  selectedBusiness: selectedBusiness,
                  onRadioChanged: (int? value) {
                    if (value != null) {
                      setState(() {
                        selectedBusiness = value;
                        storeBusinessID(value);
                        updateBusinessStatus(value);
                        if (kDebugMode) {
                          print('Selected Business ID: $value');
                        }
                      });
                    }
                  },
                  onUpdate: fetchBusinessData,
                  onDelete: () => _confirmDelete(business['id'].toString()),
                );
              },
            ),
          ),
        ],
      ),

      // Conditionally show the FloatingActionButton only if businessData has less than 3 items
      floatingActionButton: businessData.length < 3
          ? FloatingActionButton(
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
      )
          : null, // Don't show FloatingActionButton when businessData >= 3
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
  final VoidCallback onUpdate;  // For updating the list after editing
  final VoidCallback onDelete;  // For handling delete operation
  final int? selectedBusiness;  // Nullable selected business ID
  final ValueChanged<int?> onRadioChanged;  // Callback for nullable int (when selecting a business)

  const BusinessCard({
    super.key,
    required this.business,
    required this.onUpdate,
    required this.onDelete,
    required this.selectedBusiness,
    required this.onRadioChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Handle logo URL with proper formatting
    String imageUrl = business['logo'] ;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Radio button for business selection
          Radio<int?>(
            value: business['id'],  // Nullable int value for Radio
            groupValue: selectedBusiness,
            onChanged: onRadioChanged,  // Nullable int in callback
          ),

          // Expanded widget to allow the container to take available space
          Expanded(
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
                              //    print('Image load error: $error');
                                //  print('Attempted to load image from: $imageUrl');
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
                            _buildDetailRow(business['mobile_number'] ?? 'Not Provided'),
                            _buildDetailRow(business['state'] != null ? business['state']['name'] : 'Not Provided'),
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
                        //    print('Edit option selected');
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditBusinessForm(business: business),
                            ),
                          ).then((result) {
                            if (result == true) {
                              // Reload the business data if the update was successful
                              onUpdate();  // Call the onUpdate callback
                            }
                          });
                        } else if (value == 'Delete') {
                          if (kDebugMode) {
                        //    print('Delete option selected');
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
          ),

          // PopupMenu for Edit and Delete actions

        ],
      ),
    );
  }

  // Business Name with Verified Icon
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

  // Business Detail Row (Phone Number, State, etc.)
  Widget _buildDetailRow(String value, {bool isSecondaryText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: isSecondaryText ? Colors.grey : Colors.black,
        ),
      ),
    );
  }
}




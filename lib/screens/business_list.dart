import 'dart:convert';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/screens/business_form.dart';
import 'package:allinone_app/screens/edit_business_form.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BusinessList extends StatefulWidget {
  const BusinessList({super.key});

  @override
  BusinessListState createState() => BusinessListState();
}

class BusinessListState extends State<BusinessList> {
  List<dynamic> businessData = [];
  bool isLoading = true;
  int? selectedBusiness;

  @override
  void initState() {
    super.initState();
    fetchStoredBusinessID();
    fetchBusinessData();
    printActiveBusinessData();
  }



  Future<void> fetchStoredBusinessID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedBusiness = prefs.getInt('selected_business_id');
      String? activeBusinessData = prefs.getString('active_business');
      if (activeBusinessData != null) {
        final activeBusiness = json.decode(activeBusinessData);
        // Update UI or state with the active business's data if needed
        debugPrint('Active Business: $activeBusiness');
      }
    });
  }


  Future<void> storeBusinessID(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selected_business_id', id);
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

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];

        setState(() {
          businessData = data ?? [];
          isLoading = false;

          if (businessData.isNotEmpty) {
            // Find the first active business
            final activeBusiness = businessData.firstWhere(
                  (business) => business['status'] == 'active',
              orElse: () => businessData.first,
            );

            selectedBusiness = activeBusiness['id'];

            // Store active business data in shared preferences
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('active_business', json.encode(activeBusiness));
              debugPrint('Active Business Data Stored: ${json.encode(activeBusiness)}');
            });
          } else {
            // Clear preferences if no businesses are found
            clearPreferences();
            selectedBusiness = null;
            debugPrint('No business profiles found for this user.');
          }
        });
      } else if (response.statusCode == 404) {
        // Handle 404 response specifically
        setState(() {
          businessData = [];
          isLoading = false;
        });

        // Clear preferences as no data is available
        await clearPreferences();
        selectedBusiness = null;
        debugPrint('No business profiles found for this user (404).');
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        businessData = [];
      });

      debugPrint('Error fetching business data: $e');
    }
  }


  void _handleErrorResponse(http.Response response) {
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
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteBusinessProfile(businessId);
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
      isLoading = true; // Show loading indicator
    });

    final String apiUrl = 'https://ajhub.co.in/api/delete/business-profile/$businessId';
    String token = appStore.token;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Delete Response: ${json.decode(response.body)}');

        // Refresh the business data after deletion
        await fetchBusinessData();

        if (businessData.isEmpty) {
          // Clear preferences if no businesses are left
          await clearPreferences();
          debugPrint('All businesses deleted. Preferences cleared.');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business deleted successfully.')),
        );
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again later.')),
      );
      debugPrint('Error deleting business: $e');
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }


  Future<void> _updateBusinessStatus(int businessId) async {
    const String apiUrl = 'https://ajhub.co.in/api/status/business-profile/';
    String token = appStore.token;

    try {
      final response = await http.post(
        Uri.parse('$apiUrl$businessId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Find the updated business from the list
          final updatedBusiness = businessData.firstWhere(
                (business) => business['id'] == businessId,
          );

          // Store active business data in shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('active_business', json.encode(updatedBusiness));
          debugPrint('Active Business Stored: ${json.encode(updatedBusiness)}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Business ID $businessId activated successfully.')),
          );

          // Fetch updated data
          await fetchBusinessData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Failed to update business status.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update business status. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again later.')),
      );
      debugPrint('Error updating business status: $e');
    }
  }


  Future<void> printActiveBusinessData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? activeBusinessData = prefs.getString('active_business');

    if (activeBusinessData != null) {
      final activeBusiness = json.decode(activeBusinessData);

      // Print each field one by one
      debugPrint('Active Business Data:');
      debugPrint('ID: ${activeBusiness['id']}');
      debugPrint('Name: ${activeBusiness['business_name']}');
      debugPrint('Owner: ${activeBusiness['owner_name']}');
      debugPrint('Mobile: ${activeBusiness['mobile_number']}');
      debugPrint('Email: ${activeBusiness['email']}');
      debugPrint('Address: ${activeBusiness['address']}');
      debugPrint('Status: ${activeBusiness['status']}');
    } else {
      debugPrint('No active business data found in preferences.');
    }
  }


  Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_business_id');
    await prefs.remove('active_business');
    debugPrint('Preferences cleared.');
  }




  void _navigateToAddBusiness() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BusinessForm()),
    ).then((_) => fetchBusinessData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business'),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
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
                  onRadioChanged: (int? value) async {
                    if (value != null) {
                      setState(() {
                        selectedBusiness = value;
                      });

                      // Store the selected business ID in SharedPreferences
                      await storeBusinessID(value);

                      // Send API request to update the business status
                      await _updateBusinessStatus(value);
                    }
                  },
                  onUpdate: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBusinessForm(business: business),
                      ),
                    ).then((result) {
                      if (result == true) {
                        // Refresh the business data when coming back
                        fetchBusinessData();
                      }
                    });
                  },
                  onDelete: () =>
                      _confirmDelete(business['id'].toString()),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: businessData.length < 3
          ? FloatingActionButton(
        onPressed: _navigateToAddBusiness,
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      )
          : null,
    );
  }

  Widget _buildNoDataAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 60,
            color: Colors.red[600],
          ),
          const SizedBox(height: 10),
          Text(
            'No business profiles found for this user.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _navigateToAddBusiness,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Add Business'),
          ),
        ],
      ),
    );
  }

}

class BusinessCard extends StatelessWidget {
  final dynamic business;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final int? selectedBusiness;
  final ValueChanged<int?> onRadioChanged;

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
    String imageUrl = business['logo'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Radio<int?>(
            value: business['id'],
            groupValue: selectedBusiness,
            onChanged: onRadioChanged,
          ),
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
              padding: const EdgeInsets.only(left: 8, top: 8),
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
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
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
                            GestureDetector(
                              onTap: () => _showFullBusinessName(context, business['business_name']),
                              child: _buildBusinessNameRow(business['business_name'] ?? 'Not Provided'),
                            ),
                            _buildDetailRow(business['mobile_number'] ?? 'Not Provided'),
                            _buildDetailRow(business['state']?['name'] ?? 'Not Provided'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'Edit') {
                          onUpdate();
                        } else if (value == 'Delete') {
                          onDelete();
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
        ],
      ),
    );
  }

  Widget _buildBusinessNameRow(String businessName) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Available width for the business name, excluding the space for the icon and padding
        final availableWidth = constraints.maxWidth - 40; // Adjust based on padding and other UI elements

        // Calculate the maximum number of characters that can fit in the available space
        int maxChars = _calculateMaxCharsToFit(businessName, availableWidth);

        // If the name is longer than the max allowed characters, truncate it and add '...'
        String displayedName = businessName.length > maxChars
            ? '${businessName.substring(0, maxChars)}...'
            : businessName;

        return RichText(
          text: TextSpan(
            text: displayedName,
            style: GoogleFonts.poppins(
              fontSize: _calculateFontSize(displayedName, availableWidth),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Image.asset(
                    'assets/icons/verified.png',
                    width: 15,
                    height: 15,
                    fit: BoxFit.cover,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  double _calculateFontSize(String text, double availableWidth) {
    // Calculate font size dynamically based on available width and text length
    double fontSize = availableWidth / (text.length * 0.6); // 0.6 is a multiplier to approximate character width
    return fontSize.clamp(10.0, 15.0); // Ensure font size is within a reasonable range
  }

  int _calculateMaxCharsToFit(String businessName, double availableWidth) {
    // Estimate the width of each character based on font size
    double fontSize = _calculateFontSize(businessName, availableWidth); // Dynamically calculate font size
    double charWidth = fontSize * 0.6; // Approximate width of a character (can vary depending on font)

    // Calculate how many characters can fit within the available width
    int maxChars = (availableWidth / charWidth).floor();

    // Limit max characters to avoid very long text even if the space is big
    return maxChars > 25 ? 25 : maxChars; // Set a reasonable max limit for characters
  }





  Widget _buildDetailRow(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }

  // Method to show full business name in a dialog
  void _showFullBusinessName(BuildContext context, String businessName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Business Name'),
          content: Text(businessName),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

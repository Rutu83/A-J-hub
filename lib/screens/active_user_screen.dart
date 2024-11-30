import 'dart:convert';

import 'package:allinone_app/main.dart';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ActiveUserPage extends StatefulWidget {
  const ActiveUserPage({super.key});

  @override
  ActiveUserPageState createState() => ActiveUserPageState();
}

class ActiveUserPageState extends State<ActiveUserPage> {
  final TextEditingController amountController = TextEditingController(text: '599');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Key for form validation
  String adminPassword = '';
  String selectedUserId = ''; // To hold selected user_id
  double totalIncome = 0.0; // Store total income for validation
  List<Map<String, String>> users = []; // List to hold user_id and username from API response
  List<Map<String, String>> filteredUsers = []; // List for search-filtered users
  bool _isLoading = true; // Flag to track loading state
  final String _bearerToken = appStore.token; // Replace with the actual token

  @override
  void initState() {
    super.initState();
    fetchBusinessData();
  }

  Future<void> fetchBusinessData() async {
    try {
      final response = await getBusinessData(businessmodal: []);
      if (response.isNotEmpty) {
        final businessResponse = response.first; // Get the first BusinessModal
        if (businessResponse.business != null) {
          totalIncome = businessResponse.business!.totalIncome; // Fetch total income

          if (businessResponse.business!.levelDownline.isNotEmpty) {
            final levelDownline = businessResponse.business!.levelDownline;

            // Extract user_id and username from levelDownline
            users = levelDownline.map<Map<String, String>>((item) {
              return {
                'user_id': item.userId.toString(),
                'username': item.username,
              };
            }).toList();

            filteredUsers = List.from(users); // Initially show all users
          }
        }

        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching business data: $e');
      }
      setState(() {
        _isLoading = false; // Stop loading even if there's an error
      });
    }
  }

  // Filter users based on search input
  void filterUsers(String query) {
    final filteredList = users.where((user) {
      final username = user['username']?.toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      return username.contains(searchQuery); // Case insensitive search
    }).toList();

    setState(() {
      filteredUsers = filteredList;
    });
  }

  Future<void> submitActiveUserRequest() async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed.');
      return; // Stop submission if form validation fails
    }

    const String apiUrl = 'https://ajhub.co.in/api/active/user';

    try {
      final Map<String, dynamic> payload = {
        'user_id': selectedUserId,
        'amount': double.parse(amountController.text),
        'admin_password': adminPassword,
      };

      print('Submitting payload to API: $payload');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_bearerToken',
        },
        body: json.encode(payload),
      );

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('API Success: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'User activated successfully!')),
        );
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = errorData['error'] ?? 'An error occurred';
        print('API Error: $errorMessage');
        if (errorMessage.contains('Insufficient balance')) {
          // Show a specific error message for insufficient balance
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$errorMessage')),
          );
        } else {
          // Handle generic errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$errorMessage')),
          );
        }
      }
    } catch (e) {
      print('Network error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Active User',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'User Id',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () async {
                          String? selectedId = await showModalBottomSheet<String>(
                            context: context,
                            isScrollControlled: true, // Allows the bottom sheet to adjust for the keyboard
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(555)), // Top corners radius
                            ),
                            builder: (context) {
                              TextEditingController searchController = TextEditingController();
                              List<Map<String, String>> localFilteredUsers = List.from(filteredUsers);

                              return StatefulBuilder(
                                builder: (context, setState) {
                                  void filterBottomSheetUsers(String query) {
                                    setState(() {
                                      localFilteredUsers = filteredUsers.where((user) {
                                        final username = user['username']?.toLowerCase() ?? '';
                                        final userId = user['user_id'] ?? '';
                                        final searchQuery = query.toLowerCase();
                                        return username.contains(searchQuery) || userId.contains(searchQuery);
                                      }).toList();
                                    });
                                  }

                                  return Container(
                                    color: Colors.white, // Set the dropdown background color to white
                                    padding: MediaQuery.of(context).viewInsets, // Adjust for the keyboard
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: TextField(
                                              controller: searchController,
                                              decoration: InputDecoration(
                                                labelText: 'Search User',
                                                prefixIcon: const Icon(Icons.search),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                              onChanged: (value) => filterBottomSheetUsers(value),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            height: MediaQuery.of(context).size.height * 0.5, // Limit the list height
                                            child: ListView.builder(
                                              itemCount: localFilteredUsers.length,
                                              itemBuilder: (context, index) {
                                                final user = localFilteredUsers[index];
                                                return Container(
                                                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                                               //   padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.grey), // Gray border for each user item
                                                    borderRadius: BorderRadius.circular(10), // Rounded corners
                                                  ),
                                                  child: ListTile(
                                                    title: Text(
                                                      user['username'] ?? 'Unknown',
                                                      style: const TextStyle(color: Colors.black),
                                                    ),
                                                    subtitle: Text(
                                                      'User ID: ${user['user_id']}',
                                                      style: const TextStyle(color: Colors.grey),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context, user['user_id']);
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );

                          if (selectedId != null) {
                            setState(() {
                              selectedUserId = selectedId;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedUserId.isNotEmpty
                                    ? filteredUsers.firstWhere((user) => user['user_id'] == selectedUserId)['username'] ?? 'Unknown'
                                    : 'Select a user',
                                style: const TextStyle(color: Colors.black),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),






                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),




              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '₹',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Set Amount',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        enabled: false, // Disable the field
                        decoration: InputDecoration(
                          labelText: 'Set Amount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelStyle: const TextStyle(color: Colors.black),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Amount is required.'
                            : null, // Validation for amount
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      showAdminPasswordDialog(); // Open the password dialog
                    }
                  },
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: Text(
                    'Submit',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showAdminPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Admin Authorization',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter the admin password to proceed:',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 10),
              TextField(
                obscureText: true, // Hides the password input
                decoration: InputDecoration(
                  labelText: 'Admin Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  adminPassword = value; // Store the entered password
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                if (adminPassword.isEmpty) {
                  // Show error if password is not entered
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Admin password is required.')),
                  );
                } else {
                  submitActiveUserRequest(); // Proceed with submission
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Confirm',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

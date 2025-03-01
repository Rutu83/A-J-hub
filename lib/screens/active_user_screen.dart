import 'dart:convert';
import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/utils/configs.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String adminPassword = '';
  String selectedUserId = '';
  double totalIncome = 0.0;
  List<Map<String, String>> users = [];
  List<Map<String, String>> filteredUsers = [];
  bool _isLoading = true;
  final String _bearerToken = appStore.token;
  bool _isSubmitting = false;
  @override
  void initState() {
    super.initState();
    fetchBusinessData();
  }

  Future<void> fetchBusinessData() async {
    try {

      final response = await getTeamData(teammodal: []);

      if (response.isNotEmpty) {

        final teamResponse = response.first;

        if (teamResponse.users.isNotEmpty) {
          final levelDownline = teamResponse.users;


          users = levelDownline.map<Map<String, String>>((item) {
            return {
              'userId': item.userId.toString(),
              'username': item.username,
            };
          }).toList();
          filteredUsers = List.from(users);
        }
            }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {


      setState(() {
        _isLoading = false;
      });
    }
  }

  void filterUsers(String query) {
    final filteredList = users.where((user) {
      final username = user['username']?.toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      return username.contains(searchQuery);
    }).toList();

    setState(() {
      filteredUsers = filteredList;
    });
  }


  Future<void> submitActiveUserRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    const String apiUrl = '${BASE_URL}active/user';

    setState(() {
      _isSubmitting = true;
    });

    try {
      final Map<String, dynamic> payload = {
        'user_id': selectedUserId,
        'amount': double.parse(amountController.text),
        'admin_password': adminPassword,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_bearerToken',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'User activated successfully!')),
        );
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'An error occurred';

        if (errorData['error'] is Map) {
          final firstErrorKey = (errorData['error'] as Map).keys.first;
          final firstErrorValue = (errorData['error'][firstErrorKey] as List).first;
          errorMessage = firstErrorValue.toString();
        } else if (errorData['error'] is String) {
          errorMessage = errorData['error'];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false; // Hide loading indicator
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Active User',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white, // Set text color to white
          ),
        ),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red,))
          : _isSubmitting
        ? const Center(child: CircularProgressIndicator(color: Colors.red,)) :
        Padding(
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
                            'User Name',
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
                                        final userId = user['userId'] ?? '';
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
                                                      'User ID: ${user['userId']}',
                                                      style: const TextStyle(color: Colors.grey),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context, user['userId']);
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
                                    ? filteredUsers.firstWhere((user) => user['userId'] == selectedUserId)['username'] ?? 'Unknown'
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

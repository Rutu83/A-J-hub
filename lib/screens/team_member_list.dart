import 'package:flutter/material.dart';

class TeamMemberList extends StatefulWidget {
  final Map<String, dynamic> userData; // Use dynamic to handle loosely-typed data

  const TeamMemberList({super.key, required this.userData});

  @override
  TeamMemberListState createState() => TeamMemberListState();
}

class TeamMemberListState extends State<TeamMemberList> {
  int selectedLevel = 1; // Default selected level

  @override
  void initState() {
    super.initState();
    // Ensure the first level is selected by default
    selectedLevel = 1;


    print(widget.userData);


  }

  @override
  Widget build(BuildContext context) {
    final levels = List.generate(10, (index) => index + 1);
    // Cast the user data to the expected type
    final users = (widget.userData['Level $selectedLevel'] as List?)
        ?.map((user) => Map<String, String>.from(user as Map))
        .toList() ??
        []; // Ensure correct casting and handle null values




    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_new)),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ezra Mason'),
            Text(
              'xx34Ft4jk532AA',
              style: TextStyle(
                fontSize: 20, // Responsive text size
                color: Colors.black38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.groups_outlined,
              size: 30,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: Text(
              '45',
              style: TextStyle(
                fontSize: 18, // Responsive text size
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Row(
        children: [
          // Level list on the left
          Container(
            width: 70, // 20% of the screen width for levels list
            color: Colors.white, // Background color for levels
            child: ListView.builder(
              itemCount: levels.length,
              itemBuilder: (context, index) {
                int level = levels[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedLevel = level;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 23, horizontal: screenWidth * 0.02),
                    color: selectedLevel == level ? Colors.red : Colors.transparent, // Highlight selected level
                    child: Text(
                      'Level $level',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03, // Responsive text size
                        color: selectedLevel == level ? Colors.white : Colors.black38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // User details list on the right
          Expanded(
            child: Container(
              color: Colors.white, // Background color for user list
              child: Column(
                children: [
                  // Header
                  Container(
                    color: Colors.red,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        _buildHeaderCell('USERNAME', screenWidth),
                        _buildVerticalDivider(),
                        _buildHeaderCell('EMAIL', screenWidth),
                        _buildVerticalDivider(),
                        _buildHeaderCell('PHONE NUMBER', screenWidth),
                        _buildVerticalDivider(),
                        _buildHeaderCell('JOINED AT', screenWidth),
                      ],
                    ),
                  ),
                  // User rows
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];

                        return _buildUserRow(user, index, screenWidth);
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

  Widget _buildHeaderCell(String text, double screenWidth) {
    return Flexible(
      fit: FlexFit.tight, // Takes up available space as needed
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenWidth * 0.025, // Responsive text size
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUserRow(Map<String, String> user, int index, double screenWidth) {
    return Container(
      color: index % 2 == 0 ? Colors.grey.withOpacity(0.11) : Colors.grey.withOpacity(0.22), // Alternating row colors
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _buildUserCell(user['username'] ?? '', screenWidth),
          _buildVerticalDivider(),
          _buildUserCell(user['email'] ?? '', screenWidth),
          _buildVerticalDivider(),
          _buildUserCell(user['phone_number'] ?? '', screenWidth), // Changed to 'phone_number' to match your data
          _buildVerticalDivider(),
          _buildUserCell(user['created_at'] ?? '', screenWidth), // Changed to 'created_at' for join date
        ],
      ),
    );
  }

  Widget _buildUserCell(String text, double screenWidth) {
    return Flexible(
      fit: FlexFit.tight, // Takes up available space as needed
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: screenWidth * 0.025, // Responsive text size
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return const SizedBox(
      height: 50,
      child: VerticalDivider(color: Colors.white24),
    );
  }
}

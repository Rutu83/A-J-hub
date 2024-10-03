import 'package:allinone_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TeamMemberList extends StatefulWidget {
  final List<dynamic>? userData; // Make it nullable to handle cases when it's null

  const TeamMemberList({super.key, required this.userData});

  @override
  TeamMemberListState createState() => TeamMemberListState();
}

class TeamMemberListState extends State<TeamMemberList> {
  int selectedLevel = 1; // Default selected level

  // Income rates based on level
  final Map<int, int> levelIncomeRates = {
    1: 200,
    2: 40,
    3: 20,
    4: 10,
    5: 10,
    6: 5,
    7: 5,
    8: 5,
    9: 5,
    10: 5,
  };

  @override
  void initState() {
    super.initState();

    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Ensure the first level is selected by default
    selectedLevel = 1;

    if (kDebugMode) {
      print(widget.userData);
    }
  }

  @override
  void dispose() {
    // Reset to system default orientation (portrait) when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // Function to format date
  String _formatDate(String dateString) {
    // Parse the input string into a DateTime object
    DateTime parsedDate = DateTime.parse(dateString);

    // Define the format
    DateFormat formatter = DateFormat('dd MMM yyyy');

    // Return the formatted date
    return formatter.format(parsedDate);
  }

  // Function to format the income nicely (e.g. add commas or currency)
  String _formatIncome(double income) {
    return NumberFormat.currency(symbol: '₹ ', decimalDigits: 2).format(income);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final levels = List.generate(10, (index) => index + 1);

    // Filter the users by selected level
    final users = (widget.userData)
        ?.where((user) {
      var level = user['level'];
      // Check if level is already an integer or convert it to int
      return (level is int ? level : int.tryParse(level.toString())) == selectedLevel;
    })
        .map((user) => {
      'username': user['username'].toString(),
      'uid': user['uid'].toString(),
      'total_team': user['total_team'].toString(),
      'total_income': user['total_income'].toString(),
      'direct_team_count': user['direct_team_count'].toString(), // Correct key used here
      'total_team_count': user['total_team_count'].toString(), // Correct key used here
      'created_at': _formatDate(user['created_at']), // Format the created_at date
      'level': user['level'].toString(),
    })
        .toList() ?? [];

    // Calculate the selected level's fixed total income (multiplying user count by income per person)
    int userCount = users.length;
    int selectedLevelIncome = (levelIncomeRates[selectedLevel] ?? 0) * userCount;

    // Calculate the total income for all users using fixed rate logic
    double totalIncome = widget.userData?.fold(0.0, (sum, user) {
      int level = int.tryParse(user['level'].toString()) ?? 0;
      return sum! + (levelIncomeRates[level] ?? 0);
    }) ?? 0.0;

    // Get the number of users in the selected level
    int selectedLevelUserCount = users.length;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: screenHeight * 0.14, // Set the height dynamically based on screen height
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_new),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appStore.Name, // Display the name dynamically
                style: TextStyle(
                  fontSize: screenWidth * 0.021, // Responsive title font size
                ),
              ),

            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.02, top: screenHeight * 0.01, bottom: screenHeight * 0.01),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Level $selectedLevel: $selectedLevelUserCount Member | Income: ',
                      style: TextStyle(
                        fontSize: screenWidth * 0.018, // Same font size
                        color: Colors.black, // Default color
                      ),
                    ),
                    TextSpan(
                      text: _formatIncome(selectedLevelIncome.toDouble()),
                      style: TextStyle(
                        fontSize: screenWidth * 0.018,
                        color: Colors.green, // Highlight income in green
                        fontWeight: FontWeight.bold, // Make the income bold
                      ),
                    ),
                    TextSpan(
                      text: ' | Total Team: ',
                      style: TextStyle(
                        fontSize: screenWidth * 0.018,
                        color: Colors.black, // Default color
                      ),
                    ),
                    TextSpan(
                      text: '${widget.userData?.length ?? 0}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.018,
                        color: Colors.green, // Highlight total team count in green
                        fontWeight: FontWeight.bold, // Make the total team count bold
                      ),
                    ),
                    TextSpan(
                      text: ' | Total Income: ',
                      style: TextStyle(
                        fontSize: screenWidth * 0.018,
                        color: Colors.black, // Default color
                      ),
                    ),
                    TextSpan(
                      text: _formatIncome(totalIncome),
                      style: TextStyle(
                        fontSize: screenWidth * 0.018,
                        color: Colors.green, // Highlight total income in green
                        fontWeight: FontWeight.bold, // Make the total income bold
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
          ],
        ),
        body: Row(
          children: [
            // Level list on the left
            Container(
              width: screenWidth * 0.12, // Responsive width for the level list
              color: Colors.white,
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
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03, horizontal: screenWidth * 0.01),
                      color: selectedLevel == level ? Colors.red : Colors.transparent,
                      child: Text(
                        'Level $level',
                        style: TextStyle(
                          fontSize: screenWidth * 0.024, // Responsive font size for levels
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
                color: Colors.white,
                child: Column(
                  children: [
                    // Header
                    Container(
                      color: Colors.red,
                      padding: EdgeInsets.all(screenHeight * 0.01), // Responsive padding for the header
                      child: Row(
                        children: [
                          _buildHeaderCell('JOINED AT', screenWidth),
                          _buildHeaderCell('NAME', screenWidth),
                          _buildVerticalDivider(),
                          _buildHeaderCell('UID', screenWidth),
                          _buildVerticalDivider(),
                          _buildHeaderCell('Direct Circle', screenWidth),
                          _buildVerticalDivider(),
                          _buildHeaderCell('TOTAL TEAM', screenWidth),
                          _buildVerticalDivider(),
                          _buildHeaderCell('TOTAL INCOME', screenWidth),
                          _buildVerticalDivider(),
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
      ),
    );
  }

  Widget _buildHeaderCell(String text, double screenWidth) {
    return Flexible(
      fit: FlexFit.tight, // Takes up available space as needed
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenWidth * 0.020, // Responsive text size for header
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
      padding: EdgeInsets.all(screenWidth * 0.02), // Responsive padding for user rows
      child: Row(
        children: [
          _buildUserCell(user['created_at'] ?? '', screenWidth),
          _buildVerticalDivider(),
          _buildUserCell(user['username'] ?? '', screenWidth),
          _buildVerticalDivider(),
          _buildUserCell(user['uid'] ?? '', screenWidth),
          _buildVerticalDivider(),
          _buildUserCell(user['direct_team_count'] ?? '', screenWidth),
          _buildVerticalDivider(),
          _buildUserCell(user['total_team_count'] ?? "", screenWidth),
          _buildVerticalDivider(),
          _buildUserCell(user['total_income'] ?? '', screenWidth),
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
          fontSize: screenWidth * 0.019, // Responsive text size for user rows
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

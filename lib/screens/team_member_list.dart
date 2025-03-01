import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/model/business_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TeamMemberList extends StatefulWidget {
  final List<LevelDownline>? userData;

  const TeamMemberList({super.key, required this.userData});

  @override
  TeamMemberListState createState() => TeamMemberListState();
}

class TeamMemberListState extends State<TeamMemberList> {
  int selectedLevel = 1;
  static const Map<int, int> levelIncomeRates = {
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatIncome(double income) {
    return NumberFormat.currency(symbol: '₹ ', decimalDigits: 2).format(income);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final levels = List.generate(10, (index) => index + 1);
    final users = (widget.userData ?? []).where((user) => user.level == selectedLevel).toList();
    final selectedLevelIncome = levelIncomeRates[selectedLevel]! * users.length;
    final totalIncome = widget.userData?.fold<double>(0, (sum, user) {
      return sum + (levelIncomeRates[user.level] ?? 0);
    }) ?? 0.0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: screenHeight * 0.14,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new),
          ),
          title: Text(
            appStore.Name,
            style: TextStyle(fontSize: screenWidth * 0.021),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.02),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: 'Level $selectedLevel: ${users.length} Member | Income: ', style: TextStyle(fontSize: screenWidth * 0.018,color: Colors.black,)),
                    TextSpan(text: _formatIncome(selectedLevelIncome.toDouble()), style: TextStyle(fontSize: screenWidth * 0.018, color: Colors.green, fontWeight: FontWeight.bold)),
                    TextSpan(text: ' | Total Team: ', style: TextStyle(fontSize: screenWidth * 0.018,color: Colors.black,)),
                    TextSpan(text: '${widget.userData?.length ?? 0}', style: TextStyle(fontSize: screenWidth * 0.018, color: Colors.green, fontWeight: FontWeight.bold)),
                    TextSpan(text: ' | Total Income: ', style: TextStyle(fontSize: screenWidth * 0.018,color: Colors.black,)),
                    TextSpan(text: _formatIncome(totalIncome), style: TextStyle(fontSize: screenWidth * 0.018, color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Row(
          children: [
            SizedBox(
              width: screenWidth * 0.12,
              child: ListView.builder(
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return GestureDetector(
                    onTap: () => setState(() => selectedLevel = level),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
                      color: selectedLevel == level ? Colors.red : Colors.transparent,
                      child: Text(
                        'Level $level',
                        style: TextStyle(fontSize: screenWidth * 0.024, color: selectedLevel == level ? Colors.white : Colors.black38, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Column(
                children: [

                  Container(
                    color: Colors.red,
                    padding: EdgeInsets.all(screenHeight * 0.01),
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, double screenWidth) {
    return Flexible(
      fit: FlexFit.tight,
      child: Text(
        text,
        style: TextStyle(fontSize: screenWidth * 0.020, fontWeight: FontWeight.bold, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUserRow(LevelDownline user, int index, double screenWidth) {
    return Container(
      color: index % 2 == 0 ? Colors.grey.withOpacity(0.11) : Colors.grey.withOpacity(0.22),
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: Row(
        children: [
          _buildUserCell(_formatDate(user.createdAt), screenWidth),
          _buildVerticalDivider(),
          _buildUserCell(user.username, screenWidth),
          _buildVerticalDivider(),
          _buildUserCell(user.uid, screenWidth),
          _buildVerticalDivider(),
          _buildUserCell(user.directTeamCount.toString(), screenWidth),
          _buildVerticalDivider(),
          _buildUserCell(user.totalTeamCount.toString(), screenWidth),
          _buildVerticalDivider(),
          _buildUserCell(_formatIncome(user.totalIncome), screenWidth),
        ],
      ),
    );
  }

  Widget _buildUserCell(String text, double screenWidth) {
    return Flexible(
      fit: FlexFit.tight,
      child: Text(
        text,
        style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.019),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return const SizedBox(height: 50, child: VerticalDivider(color: Colors.white24));
  }
}

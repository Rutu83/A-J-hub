
import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  BusinessScreenState createState() => BusinessScreenState();
}

class BusinessScreenState extends State<BusinessScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTopCard(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRankBox("Money Plant Rank", "N/A"),
                  const SizedBox(width: 10),
                  _buildRankBox("Royalty Rank", "N/A"),
                ],
              ),
              const SizedBox(height: 20),
              _buildStatusRow("Total Active", "0", "Total InActive", "0"),
              const SizedBox(height: 10),
              _buildStatusRow("Today Active", "0", "Today InActive", "0"),
              const SizedBox(height: 20),
              _buildFooter(),


            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const Center(
            child: Text(
              "Dipak",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoRow("User ID", "8849469980"),
          _buildInfoRow("Mobile", "8849469980"),
          _buildInfoRow("Status", "Free"),
          _buildInfoRow("Date", "13-Aug-2024"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label :",
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const Divider(color: Colors.white),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String leftTitle, String leftValue, String rightTitle, String rightValue) {
    return Row(
      children: [
        _buildStatusBox(leftTitle, leftValue),
        const SizedBox(width: 10),
        _buildStatusBox(rightTitle, rightValue),
      ],
    );
  }

  Widget _buildStatusBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Divider(),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: const TextScroll(
        'This is the sample text for Flutt '
            '                                                 '
            '                                                 ',
        intervalSpaces: 0,
        style: TextStyle(
            color: Colors.white
        ),
        velocity: Velocity(pixelsPerSecond: Offset(100, 0)), // Much faster speed
        fadedBorder: true,
        delayBefore: Duration(milliseconds: 100),
        fadeBorderVisibility: FadeBorderVisibility.auto,
        fadeBorderSide: FadeBorderSide.both,
      ),
    );
  }
}

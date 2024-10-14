import 'package:flutter/material.dart';

class OportunityScreen extends StatefulWidget {
  const OportunityScreen({super.key});

  @override
  State<OportunityScreen> createState() => _OportunityScreenState();
}

class _OportunityScreenState extends State<OportunityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Set the full screen background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/framstore/framstore3.jpg'), // Replace with your image path
            fit: BoxFit.cover, // Ensures the image covers the entire screen
          ),
        ),
        // You can add more content here, such as text or buttons
        child: const Center(
          child: Text(
            'Welcome to Opportunity Screen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

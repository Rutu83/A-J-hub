import 'dart:convert';
import 'package:allinone_app/screens/dashbord_screen.dart';
import 'package:allinone_app/utils/configs.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:allinone_app/main.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
   FeedbackScreenState createState() =>  FeedbackScreenState();
}

class  FeedbackScreenState extends State<FeedbackScreen> {
  double _selectedRating = -1; // Initial rating not selected
  String _feedbackText = ""; // Feedback text
  final int _maxCharacters = 2048;
  bool _isLoading = false; // Added loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white, // Set text color to white
          ),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "How satisfied are you with the AJ Hub?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please rate your experience below by selecting an emoji.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = _getFeedbackValue(index);
                      });
                    },
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: _getFeedbackValue(index) == _selectedRating
                                ? Colors.red.withOpacity(0.2)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _getEmojiIcon(index),
                            style: TextStyle(
                              fontSize: 40,
                              color: _getFeedbackValue(index) == _selectedRating
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getEmojiText(index),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getFeedbackValue(index) == _selectedRating
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                maxLength: _maxCharacters,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: "Tell us about your experience...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16.0),
                ),
                onChanged: (value) {
                  setState(() {
                    _feedbackText = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Join 1000+ learners who’ve shared their experiences to help us improve! ✨",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : () {
                  _submitFeedback(); // Only allow button press if not loading
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  elevation: 5,
                  shadowColor: Colors.redAccent,
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text(
                  "Submit Feedback",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to map index to feedback value
  double _getFeedbackValue(int index) {
    switch (index) {
      case 0:
        return 1; // Very Dissatisfied
      case 1:
        return 2; // Dissatisfied
      case 2:
        return 3; // Neutral
      case 3:
        return 4; // Satisfied
      case 4:
        return 5; // Very Satisfied
      default:
        return 0.0; // Default
    }
  }

  String _getEmojiIcon(int index) {
    switch (index) {
      case 0:
        return '😕';
      case 1:
        return '😐';
      case 2:
        return '🙂';
      case 3:
        return '😊';
      case 4:
        return '😁';
      default:
        return '😐';
    }
  }

  String _getEmojiText(int index) {
    switch (index) {
      case 0:
        return 'Very Dissatisfied';
      case 1:
        return 'Dissatisfied';
      case 2:
        return 'Neutral';
      case 3:
        return 'Satisfied';
      case 4:
        return 'Very Satisfied';
      default:
        return '';
    }
  }

  void _submitFeedback() async {
    if (_selectedRating == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a rating before submitting.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please provide your feedback in the text box.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    // Start loading
    setState(() {
      _isLoading = true;
    });

    // Replace with your API URL and token
    const String apiUrl = "${BASE_URL}feedback";
    String token = appStore.token; // Replace with actual token

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "feedback_count": _selectedRating,
          "feedback": _feedbackText,
        }),
      );

      // Check for success responses (200 and 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print(response.body);
        }
        if (kDebugMode) {
          print(response.statusCode);
        }

        _showSuccessBottomSheet();

        setState(() {
          _selectedRating = -1;
          _feedbackText = "";
        });
      } else {
        if (kDebugMode) {
          print(response.body);
        }
        if (kDebugMode) {
          print(response.statusCode);
        }
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Failed to submit feedback. Please try again.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "An error occurred: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      // End loading after request completes
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to show success bottom sheet
  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Make the sheet size responsive to content
      builder: (context) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          height: 350, // Adjusted height to accommodate all content comfortably
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Message with Icon
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline, // Success icon
                    color: Colors.red,
                    size: 35,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Feedback Submitted Successfully!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              // Centered Image
              Center(
                child: Image.asset(
                  'assets/images/feedback.jpg', // Replace with your image asset
                  width: 150,
                  height: 150,
                ),
              ),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.thumb_up, // Thumbs-up icon for thank you message
                    color: Colors.red,
                    size: 25,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Thank you for helping us improve. Your feedback is valuable!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              // Additional message
              const Text(
                "We are constantly working to improve your experience. Stay tuned for more updates!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 10),
              // Continue Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  ); // Navigate to DashboardScreen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



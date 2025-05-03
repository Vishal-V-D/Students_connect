import 'package:flutter/material.dart';
import 'package:students_connect/screens/home.dart';

class SuccessScreen extends StatelessWidget {
  final String eventName;

  SuccessScreen({required this.eventName});

  @override
  Widget build(BuildContext context) {
    // Delay the navigation to the homepage by 1 second
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // Direct navigation to Homepage()
      );
    });

    return Scaffold(
      backgroundColor: Colors.blueAccent, // Add a background color for the screen
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                "🎉 Congratulations!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "You have successfully registered for",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "$eventName",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "You're all set to participate in the event. Keep an eye on any updates and be ready for the event day!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to home or event details
                  Navigator.pop(context); // Close the current screen (or use another route)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Correct parameter name for background color
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Go Back",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to home page or other screens
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()), // Direct navigation to Homepage()
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Correct parameter name for background color
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "View Event Details",
                  style: TextStyle(
                    fontSize: 18,
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
}

// Replace this with your actual Homepage widget

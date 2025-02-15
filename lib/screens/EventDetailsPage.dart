import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final int? eventIndex;
  final Map<String, dynamic>? event;

  EventDetailsPage({this.eventIndex, this.event});

  @override
  Widget build(BuildContext context) {
    // Use event data if provided, otherwise use eventIndex for dummy data
    final String title = event?['title'] ?? "Event ${eventIndex != null ? eventIndex! + 1 : ''}";
    final String description = event?['description'] ?? "This is the description of the event.";
    final String rules = event?['rules'] ?? "- Be on time.\n- Follow event guidelines.\n- Respect everyone.";
    final String teamSize = event?['teamSize'] ?? "3-5 members";
    final String contactPhone = event?['contactPhone'] ?? "+91 9876543210";
    final String contactEmail = event?['contactEmail'] ?? "eventorganizer@example.com";
    final String imagePath = event?['image'] ?? 'assets/event_placeholder.jpg';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          "Event Details",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Event Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),

              // Event Description
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),

              // Rules Section
              Text(
                "Rules:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                rules,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              SizedBox(height: 16),

              // Team Size
              Text(
                "Team Size:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                teamSize,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              SizedBox(height: 16),

              // Booking Button
              ElevatedButton(
                onPressed: () {
                  // Handle booking action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: Text(
                    "Book Now",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Sharing Options
              Text(
                "Share Event:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.facebook, color: Colors.blue),
                    onPressed: () {
                      // Share on Facebook
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.alternate_email, color: Colors.lightBlue),
                    onPressed: () {
                      // Share on Twitter
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.message, color: Colors.green),
                    onPressed: () {
                      // Share on WhatsApp
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.link, color: Colors.grey),
                    onPressed: () {
                      // Copy link
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Contact Section
              Text(
                "Contact Information:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    contactPhone,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    contactEmail,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

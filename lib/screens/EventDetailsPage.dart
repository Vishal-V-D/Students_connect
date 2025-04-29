import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:students_connect/screens/RegisterPage.dart';

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? event;

  EventDetailsPage({this.event});

  @override
  Widget build(BuildContext context) {
    final String name = event?['name'] ?? "Event";
    final String description = event?['description'] ?? "No description available.";
    final String rules = event?['rules'] ?? "Follow the event guidelines.";
    final String teamSize = event?['teamSize']?.toString() ?? "N/A";
    final String mode = event?['mode'] ?? "Offline";
    final String prize = event?['prize'] ?? "N/A";
    final String status = event?['status'] ?? "Pending";
    final String location = event?['location'] ?? "TBA";
    final String dateTime = event?['dateTime'] ?? "TBA";
    final String createdByName = event?['createdByName'] ?? "Unknown";
    final String createdByEmail = event?['createdByEmail'] ?? "N/A";
    final String imageUrl = event?['imageUrl'] ?? 'https://via.placeholder.com/300';
final String eventId = event?['eventID'] ?? ''; 
// Fetch document ID from Firestore if available

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey, centerTitle: true,
        title: Text(
          "Event Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA2C9E7), Color(0xFF5C768B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(description, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    Divider(height: 24, thickness: 1, color: Colors.grey[300]),
                    _buildInfoRow(Icons.calendar_today, "Date & Time:", dateTime),
                    _buildInfoRow(Icons.location_on, "Location:", location),
                    _buildInfoRow(Icons.people, "Team Size:", teamSize),
                    _buildInfoRow(Icons.sports, "Prize:", prize),
                    _buildInfoRow(Icons.event_available, "Mode:", mode),
                    Divider(height: 24, thickness: 1, color: Colors.grey[300]),
                    _buildInfoRow(Icons.person, "Organizer:", createdByName),
                    _buildInfoRow(Icons.email, "Contact:", createdByEmail),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterPage(eventId: eventId)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text("Register Now", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          SizedBox(width: 12),
          Expanded(
            child: Text("$title $value", style: TextStyle(fontSize: 16, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}

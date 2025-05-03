import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'create_event_page.dart'; // Ensure this file exists

class EventHistoryScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Creator Zone",style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.grey,
             centerTitle: true,
            ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("events").orderBy("timestamp", descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading events"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No Events Found"));
          }

          return ListView(
            padding: EdgeInsets.all(8),
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic>? eventData = doc.data() as Map<String, dynamic>?;

              if (eventData == null) return SizedBox(); // Skip invalid entries

              String eventName = eventData["name"] ?? "Unnamed Event";
              String eventDescription = eventData["description"] ?? "No description available";
              String status = eventData["status"] ?? "Pending";
              List<dynamic> tags = eventData["tags"] ?? [];
              String? imageUrl = eventData["imageUrl"];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventDetailsScreen(eventData: eventData)),
                  );
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Image
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          image: imageUrl != null && imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imageUrl == null || imageUrl.isEmpty
                            ? Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40))
                            : null,
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventName,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            SizedBox(height: 8),
                            Text(
                              eventDescription,
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.category, size: 18, color: Colors.grey[700]),
                                    SizedBox(width: 4),
                                    Text(tags.isNotEmpty ? tags.join(", ") : "No Tags",
                                        style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.event, size: 18, color: Colors.grey[700]),
                                    SizedBox(width: 4),
                                    Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: getStatusColor(status),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateEventScreen()),
    );
  },
  icon: const Icon(Icons.add, color: Colors.white),
  label: const Text(
    "Create",
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  backgroundColor: const Color.fromARGB(255, 0, 0, 0), // You can change the color as needed
),

    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;

  EventDetailsScreen({required this.eventData});

  @override
  Widget build(BuildContext context) {
    // Extracting values safely with fallbacks
    String eventName = eventData["name"]?.toString() ?? "Unnamed Event";
    String eventDescription = eventData["description"]?.toString() ?? "No description available";
    String eventDate = eventData["dateTime"]?.toString() ?? "No Date";
    String location = eventData["location"]?.toString() ?? "No Location";
   int? teamSize = eventData["teamSize"] is int 
    ? eventData["teamSize"] 
    : int.tryParse(eventData["teamSize"]?.toString() ?? '');
    String? prize = eventData["prize"]?.toString();
    String? certification = eventData["certification"]?.toString();
    List<String> tags = (eventData["tags"] as List<dynamic>?)?.cast<String>() ?? [];
    String status = eventData["status"]?.toString() ?? "Pending";
    String? imageUrl = eventData["imageUrl"]?.toString();

    return Scaffold(
      appBar: AppBar(title: Text(eventName),
          backgroundColor: Colors.grey,),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with error handling
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            SizedBox(height: 16),

            // Event Title
            Text(eventName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),

            // Event Description
            Text(eventDescription, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 16),

            // Event Details
            _buildInfoRow(Icons.event, "Date", eventDate),
            _buildInfoRow(Icons.location_on, "Location", location),
            _buildInfoRow(Icons.group, "Team Size", teamSize != null ? teamSize.toString() : "N/A"),
            if (prize != null && prize.isNotEmpty) _buildInfoRow(Icons.military_tech, "Prize", prize),
            if (certification != null && certification.isNotEmpty) _buildInfoRow(Icons.card_membership, "Certification", certification),

            SizedBox(height: 10),

            // Tags Section
            if (tags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: tags.map((tag) {
                  return Chip(label: Text(tag), backgroundColor: Colors.blueAccent.withOpacity(0.2));
                }).toList(),
              ),

            SizedBox(height: 10),

            // Status Section
            Row(
              children: [
                Text("Status: ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(status, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: getStatusColor(status))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a row for event details
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              "$title: $value",
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Determines status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

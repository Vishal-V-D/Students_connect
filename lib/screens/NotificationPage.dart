import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  final List<Map<String, dynamic>> notifications = [
    {
      "title": "Event Approved 🎉",
      "message": "Your event 'Tech Fest 2025' has been approved!",
      "icon": Icons.check_circle,
      "color": Colors.green
    },
    {
      "title": "New Event Added 📅",
      "message": "A new event 'AI Summit' is available. Check it out!",
      "icon": Icons.event,
      "color": Colors.blue
    },
    {
      "title": "OD Request Accepted ✅",
      "message": "Your OD request for 'Hackathon 2025' has been accepted.",
      "icon": Icons.verified,
      "color": Colors.green
    },
    {
      "title": "Reminder ⏰",
      "message": "Don't forget! 'Design Thinking Workshop' starts at 3:00 PM today.",
      "icon": Icons.access_time,
      "color": Colors.orange
    },
    {
      "title": "Event Cancelled ❌",
      "message": "'Music Fest 2025' has been cancelled due to unforeseen reasons.",
      "icon": Icons.cancel,
      "color": Colors.red
    },
    {
      "title": "QR Code Attendance Marked 🎟",
      "message": "Your attendance for 'ML Bootcamp' has been recorded successfully.",
      "icon": Icons.qr_code,
      "color": Colors.purple
    },
    {
      "title": "New Community Discussion 💬",
      "message": "A new discussion on 'Blockchain in Events' is trending. Join now!",
      "icon": Icons.forum,
      "color": Colors.teal
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications",style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey, centerTitle: true,
        elevation: 1,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "No new notifications",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notification["color"].withOpacity(0.2),
                      child: Icon(notification["icon"], color: notification["color"]),
                    ),
                    title: Text(
                      notification["title"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(notification["message"]),
                  ),
                );
              },
            ),
    );
  }
}

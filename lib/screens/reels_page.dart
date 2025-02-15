import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("community");
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _postMessage() async {
    String? userEmail = _auth.currentUser?.email;
    if (userEmail == null || _messageController.text.trim().isEmpty) return;

    String timestamp = DateTime.now().toIso8601String();

    await _database.push().set({
      "email": userEmail,
      "message": _messageController.text.trim(),
      "timestamp": timestamp,
    });

    _messageController.clear();
  }

  String formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserEmail = _auth.currentUser?.email;

    return Scaffold(
      appBar: AppBar(title: Text("Community")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _database.orderByChild("timestamp").onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return Center(child: Text("No messages yet. Start the discussion!"));
                }

                Map<dynamic, dynamic> messagesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<Map<String, dynamic>> messagesList = messagesMap.entries.map((entry) {
                  return {
                    "id": entry.key,
                    "email": entry.value["email"],
                    "message": entry.value["message"],
                    "timestamp": entry.value["timestamp"],
                  };
                }).toList();

                messagesList.sort((a, b) => b["timestamp"].compareTo(a["timestamp"]));

                return ListView.builder(
                  itemCount: messagesList.length,
                  itemBuilder: (context, index) {
                    var msg = messagesList[index];
                    bool isCurrentUser = msg["email"] == currentUserEmail;

                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.blue[200] : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft: isCurrentUser ? Radius.circular(12) : Radius.circular(0),
                            bottomRight: isCurrentUser ? Radius.circular(0) : Radius.circular(12),
                          ),
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg["message"],
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              isCurrentUser ? "You" : msg["email"],
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formatTimestamp(msg["timestamp"]),
                              style: TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Need help? Post here...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _postMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

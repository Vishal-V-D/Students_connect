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
  final ScrollController _scrollController = ScrollController();

  String _selectedTag = "General"; // Default tag

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _postMessage() async {
    String? userEmail = _auth.currentUser?.email;
    if (userEmail == null || _messageController.text.trim().isEmpty) return;

    String timestamp = DateTime.now().toIso8601String();

    await _database.push().set({
      "email": userEmail,
      "message": _messageController.text.trim(),
      "timestamp": timestamp,
      "tag": _selectedTag,
      "likes": 0,
    });

    _messageController.clear();
  }

  void _incrementLike(String messageId, int currentLikes) {
    _database.child(messageId).update({
      "likes": currentLikes + 1,
    });
  }

  String formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('hh:mm a').format(dateTime);
  }

  Color getAlternateColor(int index) {
    return index % 2 == 0 ? Colors.blue : Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserEmail = _auth.currentUser?.email;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("TalkTrove", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
       backgroundColor: Colors.grey,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _database.orderByChild("timestamp").onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return Center(
                    child: Text("No discussions yet.", style: TextStyle(fontSize: 16, color: Colors.black54)),
                  );
                }

                Map<dynamic, dynamic> messagesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<Map<String, dynamic>> messagesList = messagesMap.entries.map((entry) {
                  return {
                    "id": entry.key,
                    "email": entry.value["email"],
                    "message": entry.value["message"],
                    "timestamp": entry.value["timestamp"],
                    "tag": entry.value["tag"] ?? "General",
                    "likes": entry.value["likes"] ?? 0,
                  };
                }).toList();

                messagesList.sort((a, b) => b["timestamp"].compareTo(a["timestamp"]));

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  itemCount: messagesList.length,
                  itemBuilder: (context, index) {
                    var msg = messagesList[index];
                    bool isCurrentUser = msg["email"] == currentUserEmail;

                    return Stack(
                      children: [
                        if (index != messagesList.length - 1)
                          Positioned(
                            left: 27,
                            top: 40,
                            bottom: 0,
                            child: Container(
                              width: 2,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isCurrentUser
                                      ? Colors.black
                                      : getAlternateColor(index),
                                  child: Text(
                                    msg["email"][0].toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 30),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isCurrentUser ? Colors.blue.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isCurrentUser ? "You" : msg["email"].split('@')[0],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            msg["tag"],
                                            style: TextStyle(fontSize: 12, color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Text(msg["message"], style: TextStyle(fontSize: 15)),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formatTimestamp(msg["timestamp"]),
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        Row(
                                          children: [
                                            Text('${msg["likes"]}'),
                                            IconButton(
                                              icon: Icon(Icons.thumb_up_alt_outlined, size: 18),
                                              onPressed: () => _incrementLike(msg["id"], msg["likes"]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
               
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Ask a doubt or share a tip...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ClipOval(
                  child: Material(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    child: InkWell(
                      splashColor: Colors.white30,
                      onTap: _postMessage,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

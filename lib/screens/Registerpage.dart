import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:students_connect/screens/sucess_screen.dart';
import 'dart:io';
import 'qr_generator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  final String eventId;

  RegisterPage({required this.eventId});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int teamSize = 1;
  String eventName = "", eventDate = "", eventLocation = "", eventDescription = "", eventMode = "";
  final _formKey = GlobalKey<FormState>();

  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final List<TextEditingController> nameControllers = [];
  final List<TextEditingController> emailControllers = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("events")
          .where("eventID", isEqualTo: widget.eventId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot eventDoc = querySnapshot.docs.first;
        Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;

        setState(() {
          eventName = eventData["name"] ?? "Unknown Event";
          eventDate = eventData["dateTime"] ?? "TBA";
          eventLocation = eventData["location"] ?? "TBA";
          eventDescription = eventData["description"] ?? "No description available";
          eventMode = eventData["mode"] ?? "Offline";
          teamSize = int.tryParse(eventData["teamSize"] ?? "1") ?? 1;
          initializeControllers();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void initializeControllers() {
    nameControllers.clear();
    emailControllers.clear();
    for (int i = 0; i < teamSize; i++) {
      nameControllers.add(TextEditingController());
      emailControllers.add(TextEditingController());
    }
  }

  Future<void> registerTeam() async {
  if (_formKey.currentState!.validate()) {
    final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: User not logged in")),
      );
      return;
    }

    List<Map<String, String>> teamMembers = [];

    for (int i = 0; i < teamSize; i++) {
      teamMembers.add({
        "name": nameControllers[i].text.trim(),
        "email": emailControllers[i].text.trim(),
      });
    }

    // If teamSize == 1, use the first member's name as the team name
    String teamIdentifier = teamSize > 1 ? teamNameController.text.trim() : teamMembers[0]["name"]!;

    try {
      // Save registration data in Firestore
      await FirebaseFirestore.instance.collection("registrations").add({
        "eventId": widget.eventId,
        "eventName": eventName,
        "teamName": teamIdentifier,
        "teamMembers": teamMembers,
        "college": collegeController.text.trim(),
        "registeredBy": currentUserEmail, // ✅ Save the current user's email
        "timestamp": FieldValue.serverTimestamp(),
      });

      // Save registration under the logged-in user's Firestore document
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserEmail)
          .collection("registeredEvents")
          .doc(widget.eventId)
          .set({
        "eventName": eventName,
        "eventDate": eventDate,
        "eventLocation": eventLocation,
        "teamName": teamIdentifier,
        "timestamp": FieldValue.serverTimestamp(),
      });

      // Add event details under each team member's Firestore document
      for (var member in teamMembers) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(member["email"])
            .collection("registeredEvents")
            .doc(widget.eventId)
            .set({
          "eventName": eventName,
          "eventDate": eventDate,
          "eventLocation": eventLocation,
          "teamName": teamIdentifier,
          "registeredBy": currentUserEmail, // ✅ Store who registered them
          "timestamp": FieldValue.serverTimestamp(),
        });
      }

      // Send confirmation emails with QR codes
      sendEmailsWithQR(teamIdentifier, teamMembers);

      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen(eventName: eventName)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.toString()}")),
      );
    }
  }
}

  void sendEmailsWithQR(String teamName, List<Map<String, String>> teamMembers) async {
    String username = "sdgproximus@gmail.com";
    String password = "zdlcnmtxanekrrxu";
    final smtpServer = gmail(username, password);

    for (var member in teamMembers) {
      if (member["email"]!.isNotEmpty) {
        final qrFile = await QRGenerator.generateQRCode(
          teamName,
          member["email"]!,
          collegeController.text.trim(),
          eventName,
        );

        final message = Message()
          ..from = Address(username, "Event Organizer")
          ..recipients.add(member["email"]!)
          ..subject = "🎉 Registration Confirmed for $eventName"
          ..text = """
Hello,

🎉 Your team **$teamName** has successfully registered for the event:

📌 **Event Name:** $eventName  
📅 **Date & Time:** $eventDate  
📍 **Location:** $eventLocation  
📖 **Description:** $eventDescription  
🎭 **Mode:** $eventMode  

Your unique QR code is attached to this email. Please present it at the event for verification.

Best Regards,  
Event Organizer Team  
"""
          ..attachments.add(FileAttachment(qrFile)
            ..fileName = "$teamName-QRCode.png");

        try {
          await send(message, smtpServer);
        } catch (e) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register for $eventName",style: TextStyle(fontWeight: FontWeight.bold))
       ,centerTitle: true,      backgroundColor: Colors.grey,),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (teamSize > 1)
                        TextFormField(
                          controller: teamNameController,
                          decoration: InputDecoration(labelText: "Team Name"),
                          validator: (value) => value!.isEmpty ? "Enter team name" : null,
                        ),
                      for (int i = 0; i < teamSize; i++)
                        Column(
                          children: [
                            TextFormField(controller: nameControllers[i], decoration: InputDecoration(labelText: "Member ${i + 1} Name")),
                            TextFormField(controller: emailControllers[i], decoration: InputDecoration(labelText: "Email")),
                          ],
                        ),
                      TextFormField(controller: collegeController, decoration: InputDecoration(labelText: "College")),
                      SizedBox(height: 20),
                      ElevatedButton(onPressed: registerTeam, child: Text("Register", style: TextStyle(fontSize: 18))),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}


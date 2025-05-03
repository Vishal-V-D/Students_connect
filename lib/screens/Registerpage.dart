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

      String teamIdentifier = teamSize > 1
          ? teamNameController.text.trim()
          : teamMembers[0]["name"]!;

      try {
        await FirebaseFirestore.instance.collection("registrations").add({
          "eventId": widget.eventId,
          "eventName": eventName,
          "teamName": teamIdentifier,
          "teamMembers": teamMembers,
          "college": collegeController.text.trim(),
          "registeredBy": currentUserEmail,
          "timestamp": FieldValue.serverTimestamp(),
        });

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
            "registeredBy": currentUserEmail,
            "timestamp": FieldValue.serverTimestamp(),
          });
        }

        sendEmailsWithQR(teamIdentifier, teamMembers);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SuccessScreen(eventName: eventName)),
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
          ..attachments.add(FileAttachment(qrFile)..fileName = "$teamName-QRCode.png");

        try {
          await send(message, smtpServer);
        } catch (e) {}
      }
    }
  }
Widget buildStyledTextField(String label, TextEditingController controller,
    {bool isEmail = false, IconData icon = Icons.person}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Enter $label' : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 36, 34, 34)),
        labelText: label,
        labelStyle: TextStyle(color: const Color.fromARGB(255, 34, 32, 32)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

  Widget buildTextField(String label, TextEditingController controller, {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: (value) => value == null || value.isEmpty ? "Enter $label" : null,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[200],
 appBar: AppBar(
   backgroundColor: const Color.fromARGB(255, 100, 97, 97),
  toolbarHeight: 80, // Increase AppBar height
  title: Center(
    child: Text(
      "Register for $eventName",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: Colors.white,
      ),
      maxLines: 2,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    ),
  ),
  centerTitle: true, // Ensures iOS/Android consistent center
),

    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (teamSize > 1)
                      buildStyledTextField(
                        "Team Name",
                        teamNameController,
                        icon: Icons.group,
                      ),
                    ...List.generate(teamSize, (i) {
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: const Color.fromARGB(255, 200, 215, 223), 
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Member ${i + 1}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                              buildStyledTextField(
                                "Name",
                                nameControllers[i],
                                icon: Icons.person,
                              ),
                              buildStyledTextField(
                                "Email",
                                emailControllers[i],
                                isEmail: true,
                                icon: Icons.email,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    buildStyledTextField(
                      "College",
                      collegeController,
                      icon: Icons.school,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: registerTeam,
                      icon: Icon(Icons.send, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      label: Text(
                        "Register",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
  );
}

}

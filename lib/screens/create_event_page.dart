import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart'; 
class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  File? image;
  bool isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController teamSizeController = TextEditingController();
  TextEditingController prizeController = TextEditingController();
  TextEditingController certificationController = TextEditingController();
  TextEditingController customTagController = TextEditingController();

  String eventMode = "Offline"; // Default mode
  List<TextEditingController> extraFields = [];

  final List<String> predefinedTags = ["Tech", "Workshop", "Hackathon", "AI", "Coding", "Seminar"];
  List<String> selectedTags = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String cloudName = "dctn41obg";
  final String uploadPreset = "unsigned_preset"; // Replace with your Cloudinary preset

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
        });
      }
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> createEvent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showSnackbar("User not logged in!", isError: true);
      return;
    }

    String? userName = user.displayName ?? "Anonymous";
    String userEmail = user.email ?? "Unknown";

    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null ||
        locationController.text.isEmpty ||
        teamSizeController.text.isEmpty ||
        image == null) {
      showSnackbar("All required fields must be filled!", isError: true);
      return;
    }

    setState(() => isLoading = true);

    String? imageUrl = await uploadImageToCloudinary(image!);
    if (imageUrl == null) {
      setState(() => isLoading = false);
      showSnackbar("Image upload failed!", isError: true);
      return;
    }
   String eventId = Uuid().v4();
    Map<String, dynamic> eventData = {
      "eventID":eventId,
      "name": nameController.text,
      "description": descriptionController.text,
      "dateTime": "${selectedDate!.toLocal()} ${selectedTime!.format(context)}",
      "mode": eventMode,
      "location": locationController.text,
      "teamSize": teamSizeController.text,
      "prize": prizeController.text.isNotEmpty ? prizeController.text : null,
      "certification": certificationController.text.isNotEmpty ? certificationController.text : null,
      "tags": selectedTags,
      "status": "Pending",
      "imageUrl": imageUrl,
      "createdByName": userName,
      "createdByEmail": userEmail,
      "timestamp": FieldValue.serverTimestamp(),
    };

    for (var controller in extraFields) {
      if (controller.text.isNotEmpty) {
        List<String> keyValue = controller.text.split(":");
        if (keyValue.length == 2) {
          eventData[keyValue[0].trim()] = keyValue[1].trim();
        }
      }
    }

    try {
      await _firestore.collection("events").add(eventData);
      setState(() => isLoading = false);
      showSnackbar("Event Created Successfully!", isError: false);
      resetForm();
    } catch (e) {
      setState(() => isLoading = false);
      showSnackbar("Event creation failed! Error: $e", isError: true);
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    try {
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonData["secure_url"];
      } else {
        throw Exception("Upload failed: ${jsonData['error']['message']}");
      }
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      return null;
    }
  }

  void resetForm() {
    nameController.clear();
    descriptionController.clear();
    locationController.clear();
    teamSizeController.clear();
    prizeController.clear();
    certificationController.clear();
    setState(() {
      image = null;
      selectedTags.clear();
      extraFields.clear();
      selectedDate = null;
      selectedTime = null;
    });
  }

  void showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void addExtraField() {
    setState(() {
      extraFields.add(TextEditingController());
    });
  }

  void addCustomTag() {
    if (customTagController.text.isNotEmpty) {
      setState(() {
        selectedTags.add(customTagController.text);
        customTagController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Event",style: TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.grey, centerTitle: true,
),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (image != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Image.file(image!, height: 150),
                    ),
                  ElevatedButton(
                    onPressed: pickImage,
                    child: Text("Pick Image"),
                  ),
                  TextField(controller: nameController, decoration: InputDecoration(labelText: "Event Name")),
                  TextField(controller: descriptionController, decoration: InputDecoration(labelText: "Description")),
                  ListTile(
                    title: Text(selectedDate == null || selectedTime == null
                        ? "Select Date & Time"
                        : "${selectedDate!.toLocal().toString().split(' ')[0]} ${selectedTime!.format(context)}"),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDateTime(context),
                  ),
                  DropdownButtonFormField<String>(
                    value: eventMode,
                    items: ["Offline", "Hybrid"].map((mode) {
                      return DropdownMenuItem(value: mode, child: Text(mode));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        eventMode = value!;
                      });
                    },
                    decoration: InputDecoration(labelText: "Mode"),
                  ),
                  TextField(controller: locationController, decoration: InputDecoration(labelText: "Location")),
                  TextField(controller: teamSizeController, decoration: InputDecoration(labelText: "Team Size")),
                  TextField(controller: prizeController, decoration: InputDecoration(labelText: "Prize (Optional)")),
                  TextField(controller: certificationController, decoration: InputDecoration(labelText: "Certification (Optional)")),
                  Wrap(
                    spacing: 8,
                    children: predefinedTags.map((tag) {
                      return FilterChip(
                        label: Text(tag),
                        selected: selectedTags.contains(tag),
                        onSelected: (selected) {
                          setState(() {
                            selected ? selectedTags.add(tag) : selectedTags.remove(tag);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  TextField(controller: customTagController, decoration: InputDecoration(labelText: "Add Custom Tag")),
                  ElevatedButton(onPressed: addCustomTag, child: Text("Add Tag")),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: createEvent,
                    child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Create Event"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  File? image;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateTimeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController teamSizeController = TextEditingController();
  TextEditingController prizeController = TextEditingController();
  TextEditingController certificationController = TextEditingController();
  TextEditingController customTagController = TextEditingController();

  String eventMode = "Offline"; // Default mode
  List<TextEditingController> extraFields = [];

  // 🔹 Predefined Tags
  final List<String> predefinedTags = ["Tech", "Workshop", "Hackathon", "AI", "Coding", "Seminar"];
  List<String> selectedTags = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String cloudName = "dctn41obg";
  final String uploadPreset = "unsigned_preset"; // Replace with your Cloudinary preset

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> createEvent() async {
    if (nameController.text.isNotEmpty && descriptionController.text.isNotEmpty && 
        dateTimeController.text.isNotEmpty && locationController.text.isNotEmpty &&
        teamSizeController.text.isNotEmpty && image != null) {
      
      String? imageUrl = await uploadImageToCloudinary(image!);
      if (imageUrl != null) {
        Map<String, dynamic> eventData = {
          "name": nameController.text,
          "description": descriptionController.text,
          "dateTime": dateTimeController.text,
          "mode": eventMode,
          "location": locationController.text,
          "teamSize": teamSizeController.text,
          "prize": prizeController.text.isNotEmpty ? prizeController.text : null,
          "certification": certificationController.text.isNotEmpty ? certificationController.text : null,
          "tags": selectedTags,
          "status": "Pending",
          "imageUrl": imageUrl,
          "timestamp": FieldValue.serverTimestamp(),
        };

        // Add extra fields if any
        for (var controller in extraFields) {
          if (controller.text.isNotEmpty) {
            eventData[controller.text.split(":")[0].trim()] = controller.text.split(":")[1].trim();
          }
        }

        await _firestore.collection("events").add(eventData);

        // Show success popup
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content: Text("Event Created Successfully!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );

        // Close the Create Event page
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image upload failed")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All required fields must be filled!")));
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
      appBar: AppBar(title: Text("Create Event")),
      body: Padding(
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
              TextField(controller: dateTimeController, decoration: InputDecoration(labelText: "Date & Time")),
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

              SizedBox(height: 10),
              
              // 🔹 Tags Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Select Tags", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Wrap(
                spacing: 8,
                children: predefinedTags.map((tag) {
                  bool isSelected = selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        isSelected ? selectedTags.remove(tag) : selectedTags.add(tag);
                      });
                    },
                  );
                }).toList(),
              ),

              TextField(
                controller: customTagController,
                decoration: InputDecoration(labelText: "Add Custom Tag"),
              ),
              ElevatedButton(
                onPressed: addCustomTag,
                child: Text("Add Tag"),
              ),

              SizedBox(height: 10),
              ElevatedButton(
                onPressed: addExtraField,
                child: Text("Add Field"),
              ),

              Column(
                children: extraFields.map((controller) {
                  return Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(labelText: "Extra Field (e.g., Key: Value)"),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: createEvent,
                child: Text("Create Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

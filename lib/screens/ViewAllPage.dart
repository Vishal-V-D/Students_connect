import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'EventDetailsPage.dart';

class ViewAllPage extends StatefulWidget {
  @override
  _ViewAllPageState createState() => _ViewAllPageState();
}

class _ViewAllPageState extends State<ViewAllPage> {
  String searchQuery = "";
  List<String> selectedTags = [];
  String selectedMode = "All";
  String selectedDate = "Any";
  final TextEditingController searchController = TextEditingController();
  final List<String> predefinedTags = ["Tech", "Workshop", "Hackathon", "AI", "Coding", "Seminar", "Blockchain", "ML", "IOC"];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchAcceptedEvents() async {
    QuerySnapshot snapshot = await _firestore.collection("events").where("status", isEqualTo: "Accepted").get();
    return snapshot.docs.map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>}).toList();
  }

  List<Map<String, dynamic>> filterEvents(List<Map<String, dynamic>> events) {
    return events.where((event) {
      bool matchesSearch = event["name"]?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false;
      bool matchesTags = selectedTags.isEmpty || selectedTags.any((tag) => (event["tags"] ?? []).contains(tag));
      bool matchesMode = selectedMode == "All" || event["mode"] == selectedMode;
      bool matchesDate = selectedDate == "Any" || (event["dateTime"]?.startsWith(selectedDate) ?? false);
      return matchesSearch && matchesTags && matchesMode && matchesDate;
    }).toList();
  }

  void openFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Filters & Sorting", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: predefinedTags.map((tag) {
                      bool isSelected = selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        selectedColor: Colors.blueAccent,
                        backgroundColor: Colors.grey[300],
                        onSelected: (selected) {
                          setModalState(() {
                            isSelected ? selectedTags.remove(tag) : selectedTags.add(tag);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedMode,
                    decoration: InputDecoration(labelText: "Event Mode", filled: true, fillColor: Colors.grey[200]),
                    items: ["All", "Online", "Offline"].map((mode) => DropdownMenuItem(value: mode, child: Text(mode))).toList(),
                    onChanged: (value) => setModalState(() => selectedMode = value!),
                  ),
                  ElevatedButton(onPressed: () => setState(() => Navigator.pop(context)), child: Text("Apply")),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void clearFilters() {
    setState(() {
      searchQuery = "";
      selectedTags.clear();
      selectedMode = "All";
      selectedDate = "Any";
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("All Events", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey,
         centerTitle: true,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [IconButton(icon: Icon(Icons.filter_list), onPressed: openFilterDialog)],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) => setState(() => searchQuery = value),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(icon: Icon(Icons.clear), onPressed: clearFilters)
                              : null,
                          labelText: "Search Events",
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    ...selectedTags.map((tag) => Chip(
                      label: Text(tag),
                      deleteIcon: Icon(Icons.close, size: 18),
                      onDeleted: () => setState(() => selectedTags.remove(tag)),
                    )),
                    if (selectedMode != "All") Chip(label: Text(selectedMode)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchAcceptedEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No Events Found!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)));
                }
                var filteredEvents = filterEvents(snapshot.data!);
                return ListView.builder(
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    var event = filteredEvents[index];
                    String eventDate = event["dateTime"] ?? "TBD";
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      elevation: 3,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        title: Text(event["name"] ?? "Unnamed Event", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("📅 $eventDate"),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailsPage(event: event))),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
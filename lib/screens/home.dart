import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:students_connect/screens/EventDetailsPage.dart';
import 'package:students_connect/screens/NotificationPage.dart';
import 'package:students_connect/screens/ViewAllPage.dart';
import 'package:students_connect/screens/profile_page.dart';
import 'package:students_connect/screens/qr_screen.dart';

import 'package:students_connect/screens/reels_page.dart';
import 'package:students_connect/screens/event_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   List<String> selectedFilters = [];
     TextEditingController _searchController = TextEditingController();

  // Example filter categories and options

  
  bool isBookmarked = false; //
  bool _isSearchOpen = false;
String _searchQuery = "";
  String selectedTag = "";
  bool showSearch = false;


  void _toggleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _toggleSearchBar() {
    setState(() {
      showSearch = !showSearch;
      if (!showSearch) {
        _searchController.clear();
        _searchQuery = "";
      }
    });
  }


  @override
  void initState() {
    super.initState();
    fetchAcceptedEvents();
 

  }
List<int> _stackCards = []; 


  int currentIndex = 0; // Track card position

void _moveCardToBack() {
    setState(() {
      final topCard = _stackCards.removeAt(0);
      _stackCards.add(topCard);
    });
  }

  void _moveCardForward() {
    setState(() {
      final lastCard = _stackCards.removeLast();
      _stackCards.insert(0, lastCard);
       
    });
  }

    void _onCardTap() {
    _moveCardForward();
  }
   List<Map<String, dynamic>> events = [];

  List<Map<String, dynamic>> acceptedEvents = [];
 List<Map<String, dynamic>> _events = [];
 

Future<void> fetchAcceptedEvents() async {
  try {
    print("Fetching events from Firestore...");

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("events")
        .get(); // Fetch all events first

    List<Map<String, dynamic>> allEvents = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    print("All Events: ${allEvents.length}");
    for (var event in allEvents) {
      print("Event: ${event['title']} | Status: ${event['status']}");
    }

    // Filter accepted events (case-insensitive)
    List<Map<String, dynamic>> acceptedEvents = allEvents
        .where((event) => (event["status"]?.toString().toLowerCase() ?? "") == "accepted")
        .toList();

    print("Accepted Events: ${acceptedEvents.length}");
    for (var event in acceptedEvents) {
      print("Accepted Event: ${event['title']} | Status: ${event['status']}");
    }

    setState(() {
      _events = acceptedEvents;
      _stackCards = List.generate(_events.length, (index) => index);
    });

    print("Stack Cards: $_stackCards");
  } catch (e) {
    print("Error fetching events: $e");
  }
}



  @override
  Widget build(BuildContext context) {



    return Scaffold(
       appBar: AppBar(
          backgroundColor: Colors.grey,
          elevation: 1, 
          title: Text(
                  "Event Hub",
                  style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold),
                ),
          actions: [
            IconButton(
              icon: Icon(Icons.qr_code_scanner, color: Colors.black87),
              onPressed: () {Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScannerScreen()),
    );
                 
              },
            ), IconButton(
      icon: Icon(Icons.notifications, color: Colors.black87),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationPage()),
        );
      },
    ),
            
            
          ],
        ),
           
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title for Top Picks
            SizedBox(height: 16),
            Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Top Picks",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                     Row(
  children: [
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewAllPage()),
        );
      },
      child: Text(
        "View all  ",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    ),
  ],
),

                      
                    ],
                    
                  ),  
                ),
       SizedBox(height: 8),
       if (selectedFilters.isNotEmpty)
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 6, // Reduce spacing for compact look
          runSpacing: 6,
          children: selectedFilters.map((filter) {
            return Chip(
              label: Text(
                filter,
                style: TextStyle(fontSize: 12, color: Colors.black87), // Smaller text
              ),
              backgroundColor: Colors.grey[300], // Light grey color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Rounded shape
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Makes it smaller
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Compact padding
              visualDensity: VisualDensity(horizontal: -2, vertical: -2), // Adjust density
              deleteIcon: Icon(Icons.close, size: 16, color: Colors.black54), // Smaller close icon
              onDeleted: () {
                setState(() {
                  selectedFilters.remove(filter);
                });
              },
            );
          }).toList(),
        ),
      ),

            // Horizontal Scrollable Cards
            SizedBox(height: 12),
       Padding(
  padding: EdgeInsets.symmetric(vertical: 16),
   child: _events.isEmpty
          ? Center(child: Text("Fetching events..."))
          : Container(
              height: 230,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsPage(event: event),
                        ),
                      );
                    },
                child: Container(
                  width: 330,
                
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Placeholder for Image
                      Container(
                        height: 95,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                         child: event["imageUrl"] != null && event["imageUrl"].isNotEmpty
      ? ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.network(
            event["imageUrl"]!,
            width: double.infinity,
            height: 90,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.blueAccent.withOpacity(0.2), // Fallback placeholder color
                height: 95,
              );
            },
          ),
        )
      : Container(
          color: Colors.blueAccent.withOpacity(0.2), // Placeholder color
          height: 95,
        
),
                      ),
                      
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                event["name"] ?? "No Title",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                event["description"] ??  "This is a brief description of ${event["title"]}.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color.fromARGB(255, 57, 55, 55),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.category, size: 18, color: Colors.grey[700]),
                                      SizedBox(width: 4),
                                      Text(
                                     (event["tags"] != null && event["tags"] is List && event["tags"].isNotEmpty) 
                          ? event["tags"][0] 
                          : "Unknown",
                        
                                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.event, size: 18, color: Colors.grey[700]),
                                      SizedBox(width: 4),
                                      Text(
                                       event["entry"] ?? "Free Entry",
                                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
                ),
              );
            },
          ),
        ),
),



            SizedBox(height: 16),

            // Stacked Event Cards with Title and Navigation
             Column(
              children: [
                // Title and Buttons for Navigation
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Explore More Events",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios, color: Colors.grey[600]),
                            onPressed: _moveCardForward,
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
                            onPressed: _moveCardToBack,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Center(
  child: GestureDetector(
    onTap: _moveCardToBack,
    child: SingleChildScrollView(
      child: SizedBox(
        height: 600, // Adjust this height as needed
        child: Stack(
          alignment: Alignment.center,
          children: _stackCards.map((index) {
             var event = _events[index];
            return AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: index == 0
                  ? 30 // Adjust top offset for the first card
                  : 50 + (index * 15).toDouble(), // Adjust spacing for other cards
              child: Transform.scale(
                scale: index == 0 ? 1.0 : 0.95,
                child: Card(
                  color: Color.fromARGB(255, 180, 195, 210),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Color.fromARGB(255, 0, 0, 0), // Border color
                      width: 2, // Border thickness
                    ),
                  ),
                  child: Container(
                    width: 350,
                    height: 460, // Increase card height if needed
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                            child: _events[index]['imageUrl'] != null
        ? Image.network(
            _events[index]['imageUrl'],
            fit: BoxFit.cover,
            width: double.infinity, // Ensures image takes full width
            height: 200,
          )
        : Center(
            child: Text(
              "Image Placeholder",
              style: TextStyle(color: Colors.black54),
            ),
          ), ),
                        SizedBox(height: 7),
                        Text(
                         event['name'] ?? "Event",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                         event['description'] ??
                                  "This is a detailed description of event.",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500, 
                            color: const Color.fromARGB(179, 35, 35, 35),
                          ),
                        ),
                        
                        // Other buttons and widgets
                        Row(
      children: [
        IconButton(
  onPressed: () {
    // Optional: Leave onPressed empty as PopupMenuButton will handle the dropdown
  },
  icon: PopupMenuButton<String>(
    onSelected: (value) {
      // Handle selection
      switch (value) {
        case 'Facebook':
          // Handle Facebook share
          break;
        case 'Twitter':
          // Handle Twitter share
          break;
        case 'WhatsApp':
          // Handle WhatsApp share
          break;
        case 'Copy Link':
          // Handle Copy Link functionality
          break;
      }
    },
    icon: Icon(Icons.share, color: const Color.fromARGB(255, 69, 69, 69)),
    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      PopupMenuItem<String>(
        value: 'Facebook',
        child: Row(
          children: [
            Icon(Icons.facebook, color: Colors.blue),
            SizedBox(width: 8),
            Text('Facebook'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'Twitter',
        child: Row(
          children: [
            Icon(Icons.alternate_email, color: Colors.lightBlue),
            SizedBox(width: 8),
            Text('Twitter'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'WhatsApp',
        child: Row(
          children: [
            Icon(Icons.message, color: Colors.green),
            SizedBox(width: 8),
            Text('WhatsApp'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'Copy Link',
        child: Row(
          children: [
            Icon(Icons.link, color: Colors.grey),
            SizedBox(width: 8),
            Text('Copy Link'),
          ],
        ),
      ),
    ],
  ),
),

       IconButton(
            onPressed: () {
              setState(() {
                isBookmarked = !isBookmarked; // Toggle the bookmark state
              });
            },
            icon: Icon(
              isBookmarked ? Icons.bookmarks : Icons.bookmarks_outlined, // Dynamic icon
              color: const Color.fromARGB(255, 75, 74, 74),
            ),
          ),
      ],
    ),

                                      // Explore Button and Three-dot Menu
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EventDetailsPage(event: _events[index]),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(255, 0, 0, 0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
    "Explore",
    style: TextStyle(
      color: Colors.white, // Set the text color to white
    ),
  ),
                                            
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return Container(
                                                    color: Colors.grey[100],
                                                    child: Wrap(
                                                      children: [
                                                        ListTile(
                                                          leading: Icon(Icons.favorite, color: Colors.red),
                                                          title: Text("Add to Favorites"),
                                                          onTap: () {
                                                            Navigator.pop(context);
                                                          },
                                                        ),
                                                        ListTile(
                                                          leading: Icon(Icons.notifications, color: Colors.grey[700]),
                                                          title: Text("Notify Me"),
                                                          onTap: () {
                                                            Navigator.pop(context);
                                                          },
                                                        ),
                                                        ListTile(
                                                          leading: Icon(Icons.schedule, color: Colors.blue),
                                                          title: Text("Schedule"),
                                                          onTap: () {
                                                            Navigator.pop(context);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(255, 251, 250, 250).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(Icons.more_vert, color: const Color.fromARGB(255, 41, 41, 41)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ),
  ),
),
      ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
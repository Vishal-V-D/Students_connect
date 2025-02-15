import 'package:flutter/material.dart';
import 'package:students_connect/screens/EventDetailsPage.dart';
import 'package:students_connect/screens/profile_page.dart';
import 'package:students_connect/screens/reels_page.dart';
import 'package:students_connect/screens/event_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   List<String> selectedFilters = [];
     TextEditingController _searchController = TextEditingController();

  // Example filter categories and options
  final Map<String, List<String>> filterOptions = {
    'Departments': ['CSE', 'ECE', 'EEE', 'Mechanical', 'Civil', 'Biotech'],
    'Event Type': ['Hackathon', 'Workshop', 'Fest','Technology', 'Webinar', 'Competition'],
    'Audience': ['Inter-College', 'Intra-College', 'Community-Based'],
    'Genre': ['Technical', 'Cultural','Tchnology', 'Sports', 'Art & Design'],
    'Prize': ['Low to High', 'High to Low'],
    'Rating': ['Top Rated', 'Most Popular'],
    'Demand': ['High Demand', 'Trending Now'],
  };
 
  
  bool isBookmarked = false; //
  bool _isSearchOpen = false;
String _searchQuery = "";
  String selectedTag = "";
  bool showSearch = false;

  List<Map<String, String>> events = [
    {"title": "Tech Conference", "tag": "Technology"},
    {"title": "Music Fest", "tag": "Entertainment"},
    {"title": "Startup Meetup", "tag": "Business"},
    {"title": "AI Summit", "tag": "Technology"},
    {"title": "Art Expo", "tag": "Art"},
  ];

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


  List<int> _stackCards = [0, 1, 2, 3, 4,5,6];

 void _showFilterDialog() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows custom height
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.5, // Opens at half the screen height
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  // Scrollable List to Prevent Overflow
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (selectedFilters.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: selectedFilters.map((filter) {
                                return Chip(
                                  label: Text(
                                    filter,
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  backgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  deleteIcon: Icon(Icons.close, size: 18, color: Colors.black54),
                                  onDeleted: () {
                                    setState(() {
                                      selectedFilters.remove(filter);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 12),
                          ],

                          // Filter Options
                          ...filterOptions.entries.map((entry) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: entry.value.map((option) {
                                    return ChoiceChip(
                                      label: Text(option),
                                      labelStyle: TextStyle(
                                        color: selectedFilters.contains(option)
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      backgroundColor: Colors.grey[300],
                                      selectedColor: Colors.blue,
                                      selected: selectedFilters.contains(option),
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            selectedFilters.add(option);
                                          } else {
                                            selectedFilters.remove(option);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 16),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),

                  // Apply & Reset Buttons
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Text('Apply', style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedFilters.clear();
                            });
                          },
                          child: Text('Reset All', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}



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


  @override
  Widget build(BuildContext context) {
  List<Map<String, String>> filteredEvents = events.where((event) {
    bool matchesSearch = event["title"]!.toLowerCase().contains(_searchQuery) ||
        event["tag"]!.toLowerCase().contains(_searchQuery);

    bool matchesTags =
        selectedFilters.isEmpty || selectedFilters.contains(event["tag"]);

    return matchesSearch && matchesTags;
  }).toList();

    return Scaffold(
       appBar: AppBar(
          backgroundColor: Colors.grey[200],
          elevation: 1,
          leading: IconButton(
            icon: Icon(showSearch ? Icons.arrow_back : Icons.search, color: Colors.black87),
            onPressed: _toggleSearchBar,
          ),
          title: showSearch
              ? TextField(
                  controller: _searchController,
                  onChanged: _toggleSearch,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none,
                  ),
                )
              : Text(
                  "Event Hub",
                  style: TextStyle(color: Colors.black87),
                ),
          actions: [
            IconButton(
              icon: Icon(Icons.qr_code_scanner, color: Colors.black87),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.filter_list_outlined, color: Colors.black87),
              onPressed: _showFilterDialog,
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
                          Text(
                        "View all  ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
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
  child: filteredEvents.isEmpty
      ? Center(child: Text("No events found"))
      : Container(
          height: 230,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              final event = filteredEvents[index];
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
                  width: 300,
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
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event["title"]!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "This is a brief description of ${event["title"]}.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
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
                                    Text(
                                      event["tag"]!,
                                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.event, size: 18, color: Colors.grey[700]),
                                    SizedBox(width: 4),
                                    Text(
                                      "Free Entry",
                                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
                    height: 450, // Increase card height if needed
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "Image Placeholder",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Event ${index + 1}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "This is a detailed description of event ${index + 1}.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
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
                                                  builder: (context) => EventDetailsPage(eventIndex: index),
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
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(Icons.more_vert, color: Colors.white),
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

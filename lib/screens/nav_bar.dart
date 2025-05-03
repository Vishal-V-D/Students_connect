import 'package:cloudinary_url_gen/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:students_connect/screens/Dash.dart';
import 'package:students_connect/screens/Paperlessod_dart';
import 'package:students_connect/screens/create_event_page.dart';
import 'package:students_connect/screens/home.dart';
import 'package:students_connect/screens/profile_page.dart';
import 'package:students_connect/screens/reels_page.dart';
import 'package:students_connect/screens/event_page.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  _NavPageState createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    
    HomePage(),
  EventHistoryScreen(),
CommunityPage(),
PaperlessODPage(),
DashboardClone(),
    
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  currentIndex: _currentIndex,
  onTap: _onTabTapped,
  selectedItemColor: Colors.black,    // Color for selected item
  unselectedItemColor: const Color.fromARGB(255, 117, 117, 117),   // Color for unselected items
  showUnselectedLabels: true,
  items: [
   
BottomNavigationBarItem(
  icon: Icon(
    _currentIndex == 0 ? Icons.emoji_events : Icons.emoji_events_outlined,
  ),
  label: 'Explore',
),
BottomNavigationBarItem(
  icon: Icon(
    _currentIndex == 1 ? Icons.event : Icons.event_note_sharp,
  ),
  label: 'Create',
),
BottomNavigationBarItem(
  icon: Icon(
    _currentIndex == 3 ? Icons.people_alt_rounded : Icons.people_outline_sharp,
  ),
  label: 'Community',
),
BottomNavigationBarItem(
  icon: Icon(
    _currentIndex == 3 ? Icons.library_books : Icons.library_books_outlined,
  ),
  label: 'E-OD',
),

  BottomNavigationBarItem(
  icon: Icon(
    _currentIndex == 4 ? Icons.dashboard_rounded : Icons.dashboard_outlined,
  ),
  label: 'Insights',
),  
  ],
),

    );
  }
}

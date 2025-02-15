import 'package:cloudinary_url_gen/config/api_config.dart';
import 'package:flutter/material.dart';
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
    ProfilePage(),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_sharp),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Community',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            label: 'E-OD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  List<String> _registeredEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.email).get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;
        });
      }
    }
    _fetchRegisteredEvents();
  }

  Future<void> _fetchRegisteredEvents() async {
    if (_user != null) {
      QuerySnapshot registrations = await _firestore
          .collection('registered_events')
          .where('email', isEqualTo: _user!.email)
          .get();

      List<String> events =
          registrations.docs.map((doc) => doc["event"].toString()).toList();

      setState(() {
        _registeredEvents = events;
      });
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, "/auth");
  }

  @override
  Widget build(BuildContext context) {
    final String userName = _userData?["name"] ?? "Guest";
    final String email = _user?.email ?? "Not Available";
    final String? profileImage = _userData?["profileImage"];

    return Scaffold(
      backgroundColor: Colors.white,  // Light mode background
      appBar: AppBar(
         backgroundColor: Colors.grey, centerTitle: true,// Light app bar color
    
        title: const Text(
          "Profile",
          style: TextStyle(color: Color.fromARGB(255, 8, 8, 8), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color.fromARGB(255, 0, 0, 0)),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileHeader(userName, email, profileImage),
            const SizedBox(height: 30),
            _buildSectionCard("Upcoming Events", _userData?["upcomingEvents"] ?? []),
            const SizedBox(height: 20),
            _buildSectionCard("Registered Events", _registeredEvents),
            const SizedBox(height: 30),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String userName, String email, String? profileImage) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: const Color.fromARGB(255, 134, 134, 134), // Light background for the avatar
            backgroundImage: profileImage != null ? NetworkImage(profileImage) : null,
            child: profileImage == null
                ? Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 50, color: Colors.white),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 10),
        Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        Text(email, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        const SizedBox(height: 10),
        const Divider(color: Colors.black26, thickness: 1, indent: 50, endIndent: 50),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<dynamic> items) {
    return Card(
      color: const Color.fromARGB(255, 230, 230, 230), // Card color for light mode
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
            const Divider(color: Colors.black26, thickness: 1),
            const SizedBox(height: 10),
            items.isEmpty
                ? const Text("No events available.", style: TextStyle(color: Colors.black54))
                : Column(
                    children: items.map((event) => ListTile(
                      title: Text(
                        event.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    )).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      color: const Color.fromARGB(255, 230, 230, 230),   // Light card color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Settings & Options", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
            const Divider(color: Colors.black26, thickness: 1),
            const SizedBox(height: 10),
            _buildSettingsTile(Icons.settings, "Settings", "/settings"),
            _buildSettingsTile(Icons.lock, "Privacy Policy", "/privacy"),
            _buildSettingsTile(Icons.help_outline, "Help & Support", "/help"),
            _buildSettingsTile(Icons.info_outline, "About", "/about"),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: const TextStyle(color: Colors.black54)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 18),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}

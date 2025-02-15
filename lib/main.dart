import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:students_connect/screens/nav_bar.dart';
import 'firebase_options.dart';
import 'package:students_connect/screens/get_inputs.dart';
import 'package:students_connect/screens/auth_screen.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Cloudinary
  var cloudinary = Cloudinary.fromStringUrl(
    'cloudinary://432423124933364:6vz_sv9qjYxyIgfnhOxammw6ykM@dctn41obg',
  );

  cloudinary.config.urlConfig.secure = true;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Students Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data!;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (userSnapshot.hasError) {
                  return Scaffold(
                    body: Center(child: Text("Error: ${userSnapshot.error}")),
                  );
                }
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  return const NavPage(); // User data exists
                } else {
                  return const GetInputs(); // Ask for additional inputs
                }
              },
            );
          }
          return const AuthScreen(); // If user is not signed in
        },
      ),
    );
  }
}


import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final String eventName;

  SuccessScreen({required this.eventName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("🎉 Successfully registered for $eventName!")),
    );
  }
}

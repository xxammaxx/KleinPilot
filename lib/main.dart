import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const KleinPilotApp());
}

/// KleinPilot — Local-first Android app for preparing manual
/// Kleinanzeigen listing drafts.
///
/// No network calls, no auto-posting, no scraping, no telemetry.
class KleinPilotApp extends StatelessWidget {
  const KleinPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KleinPilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

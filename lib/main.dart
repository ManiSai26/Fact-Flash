import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fact_flash/screens/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase.
  // Note: For a real app, you must configure your platform-specific options.
  // If no config is present, we try to initialize with default options if possible,
  // or catch the error to allow the mock service to run.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed or not configured: $e');
    debugPrint('Running with Mock Data only.');
  }
  runApp(const FactFlashApp());
}

class FactFlashApp extends StatelessWidget {
  const FactFlashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fact Flash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EA), // Deep Purple
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      home: const StartScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Pls don't delete, this is the connection to the app and database -_-"
  runApp(const MomentApp());
}

class MomentApp extends StatelessWidget {
  const MomentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOMent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A), // Deep Purple
          secondary: const Color(0xFFF48FB1), // Soft Pink
        ),
        // Google Font "Poppins"
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
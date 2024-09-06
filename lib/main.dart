import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TODO App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          primary: Colors.black, // Primary color for elements like AppBar
          onPrimary: Colors.white, // Text color on primary color
          secondary: Colors.grey, // Secondary color for elements
        ),
        scaffoldBackgroundColor: Colors.white, // Background color of the app
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black, // Background color of the AppBar
          foregroundColor: Colors.white, // Text color of the AppBar
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(), // Defines the launch screen of the app
    );
  }
}

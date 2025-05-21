import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/presentaion/screen/home.screen.dart';
import './presentaion/screen/login.screen.dart'; // Corrected path
import './presentaion/screen/signup.screen.dart'; // Add this import
import 'package:inspector/inspector.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StaffSync',
      theme: ThemeData(primarySwatch: Colors.blue),
      builder:
          (context, child) =>
              Inspector(child: child!), // Wrap [child] with [Inspector]
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Set initial screen to Login
      routes: {
        '/login': (context) => const LoginPage(), // Define Login route
        '/signup': (context) => const SignupScreen(), // Define Signup route
        '/home' : (context) => const HomeScreen()
      },
    );
  }
}

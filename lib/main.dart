import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './presentaion/screen/login.screen.dart'; // Corrected path
import './presentaion/screen/signup.screen.dart'; // Add this import

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Set initial screen to Login
      routes: {
        '/login': (context) => const LoginPage(), // Define Login route
        '/signup': (context) => SignupScreen(), // Define Signup route
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/presentaion/screen/employee.dart';
import 'package:staffsync/presentaion/screen/employee.home.dart';
import 'package:staffsync/presentaion/screen/manager.dart';
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
      theme: ThemeData(primarySwatch: Colors.orange),
      builder:
          (context, child) =>
              Inspector(child: child!), // Wrap [child] with [Inspector]
      debugShowCheckedModeBanner: false,
      home: const LoginPage(), // Set initial screenr to Login
      routes: {
       
        '/signup': (context) => const SignupScreen(), 
        '/employee/home' : (context) =>  const EmployeeLogic(),
        '/manager/home' : (context) => const ManagerScreen()
      },
    );
  }
}

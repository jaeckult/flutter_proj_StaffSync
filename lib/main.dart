import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staffsync/presentaion/screen/change.password.dart';
import 'package:staffsync/presentaion/screen/edit.profile.dart';
import 'package:staffsync/presentaion/screen/employee.dart';
import 'package:staffsync/presentaion/screen/employee.home.dart';
import 'package:staffsync/presentaion/screen/manager.dart';
import 'package:staffsync/presentaion/screen/managerHome.dart';
import 'package:staffsync/presentaion/screen/notification.screen.dart';
import 'package:staffsync/presentaion/screen/notification.setting.dart';
import './presentaion/screen/login.screen.dart';
import './presentaion/screen/signup.screen.dart';
import 'package:inspector/inspector.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/employee/home',
        builder: (context, state) => const EmployeeLogic(),
      ),
      GoRoute(
        path: '/manager/home',
        builder: (context, state) => const ManagerLogic(),
      ),
      GoRoute(
        path: '/setting',
        builder: (context, state) => const NotificationSetting(),
      ),
      GoRoute(
        path: '/changePassword',
        builder: (context, state) => const ChangePassword(),
      ),
      GoRoute(
        path: '/editProfile',
        builder: (context, state) => const EditProfile(),
      ),
      GoRoute(
        path: '/notification',
        builder: (context, state) => NotificationList(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'StaffSync',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      builder: (context, child) => Inspector(child: child!),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

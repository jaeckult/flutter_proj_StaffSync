import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staffsync/presentaion/screen/employee.collegues.Screen.dart';
import 'package:staffsync/presentaion/screen/employee.holidayScreen.dart';
import 'package:staffsync/presentaion/screen/managerColleagues.dart';
import 'package:staffsync/presentaion/screen/managerDashboard.dart';
import 'package:staffsync/presentaion/screen/managerHoliday.dart';
import 'package:staffsync/presentaion/screen/managerHome.dart';
import 'package:staffsync/presentaion/screen/employee.profileScreen.dart';
import 'package:staffsync/presentaion/screen/employee.scheduleScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Staff sync',
      debugShowCheckedModeBanner: false,
    );
  }
}

class ManagerNavigationManager {
  int currentIndex = 0;

  void onItemTapped(BuildContext context, int index) {
    currentIndex = index;
    switch (index) {
      case 0:
        context.go('/manager/home');
        break;
      case 1:
        context.go('/manager/schedule');
        break;
      case 2:
        context.go('/manager/colleagues');
        break;
      case 3:
        context.go('/manager/holiday');
        break;
      case 4:
        context.go('/manager/profile');
        break;
    }
  }
}

class ManagerLogic extends ConsumerStatefulWidget {
  const ManagerLogic({super.key});
  @override
  _ManagerLogicState createState() => _ManagerLogicState();
}

class _ManagerLogicState extends ConsumerState<ManagerLogic> {
  final ManagerNavigationManager _logic = ManagerNavigationManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ref.read(techniciansNotifierProvider.notifier).loadTechnicians();
      // ref.read(customerNotifierProvider.notifier).loadAllCustomers();
      // ref.read(techniciansNotifierProvider.notifier).loadPendingTechnicians();
      // ref.read(techniciansNotifierProvider.notifier).loadSuspendedTechnicians();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const ManagerHomeScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _logic.currentIndex,
        onTap: (index) {
          setState(() {
            _logic.onItemTapped(context, index);
          });
        },
        iconSize: 24,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 20),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule, size: 20),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, size: 20),
            label: 'Collegues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.holiday_village, size: 20),
            label: 'Holiday',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 20),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/presentaion/screen/employee.collegues.Screen.dart';
import 'package:staffsync/presentaion/screen/employee.holidayScreen.dart';
import 'package:staffsync/presentaion/screen/employee.home.dart';
import 'package:staffsync/presentaion/screen/employee.profileScreen.dart';
import 'package:staffsync/presentaion/screen/employee.scheduleScreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff sync',
      debugShowCheckedModeBanner: false,
    );
  }
}

class EmployeeNavigationManager {
  int currentIndex = 0;

  void onItemTapped(BuildContext context, int index) {
    currentIndex = index;
  }

  Widget getCurrentPage() {
    switch (currentIndex) {
      case 0:
        return const EmployeeHomeScreen();
      case 1:
        return const ScheduleScreen();
      case 2:
        return const EmployeeListScreen();
      case 3:
        return const EmployeeHolidayScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const EmployeeHomeScreen();
    }
  }
}

class EmployeeLogic extends ConsumerStatefulWidget {
  const EmployeeLogic({super.key});
  @override
  _EmployeeLogicState createState() => _EmployeeLogicState();
}

class _EmployeeLogicState extends ConsumerState<EmployeeLogic> {
  final EmployeeNavigationManager _logic = EmployeeNavigationManager();

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
  
      body: _logic
          .getCurrentPage(), // Display the current page based on the current index
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
            icon: Icon(
              Icons.home,
              size: 20,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.schedule,
              size: 20,
            ),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, size: 20),
            label: 'Collegues',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.holiday_village,
              size: 20,
            ),
            label: 'Holiday',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 20,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/providers/providers.dart';

import 'package:intl/intl.dart';
import 'package:staffsync/presentaion/screen/employee.profileScreen.dart';
import 'package:staffsync/presentaion/screen/employee.scheduleScreen.dart';
void main() => runApp(ProviderScope(child: EmployeeHomeApp()));

class EmployeeHomeApp extends StatelessWidget {
  const EmployeeHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EmployeeHomeScreen(),
    );
  }
}

class EmployeeHomeScreen extends ConsumerStatefulWidget {
  const EmployeeHomeScreen({super.key});
   @override
 ConsumerState<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
   
 
 
 }
  class _EmployeeHomeScreenState extends ConsumerState<EmployeeHomeScreen>{
  
    @override

    void initState() {
      super.initState();
      Future.microtask(() => ref.read(userNotifierProvider.notifier).loadUserFromStorage());
    }
    void _handleAttendance() async {
  try {
    await ref.read(attendanceNotifierProvider.notifier).checkIn();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-in successful')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Check-in failed: ${e.toString()}')),
    );
  }
}

  @override

  Widget build(BuildContext context) {
   


    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            const _ProfileSection(),
            const _DateSelector(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  const [
                    _TodayAttendance(),
                    SizedBox(height: 16),
                    Text("Your Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    _ActivityItem(date: "Apr 9, 2024", time: "10:20 AM"),
                    _ActivityItem(date: "Apr 8, 2024", time: "10:20 AM"),
                    _ActivityItem(date: "Apr 7, 2024", time: "10:20 AM"),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _handleAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.all(24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Check In", style: TextStyle(fontSize: 16, color:Color.fromRGBO(255, 255, 255, 1))),
              ),
            ),
          ],
        ),
      ),
      
    );
  }
 
}
  




    
  @override
 class _ProfileSection extends ConsumerWidget {
  const _ProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);
    return ListTile(
      leading: const CircleAvatar(
        radius: 24,
        backgroundImage: AssetImage('profile.png'),
      ),
      title: Text(user?.profile.fullName ?? "Loading...", style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(user?.profile.designation ?? "Loading..."),
      trailing: const Icon(Icons.notifications_none),
    );
  }
}


class _DateSelector extends StatelessWidget {
  const _DateSelector();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dates = List.generate(6, (i) => now.add(Duration(days: i)));
 
    final selectedIndex = 0;

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = index == selectedIndex;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 6)]
                  : [],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date), 
                    style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TodayAttendance extends StatelessWidget {
  const _TodayAttendance();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: const [
            _AttendanceCard(title: "Check In", value: "10:20 AM", status: "On Time", icon: Icons.login),
            _AttendanceCard(title: "Check Out", value: "7:20 PM", status: "Go Home", icon: Icons.logout),
            _AttendanceCard(title: "Break Time", value: "10:20 AM", status: "Break Time", icon: Icons.breakfast_dining),
            _AttendanceCard(title: "Total Days", value: "28", status: "Working Days", icon: Icons.calendar_today),
          ],
        ),
      ],
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final String title;
  final String value;
  final String status;
  final IconData icon;

  const _AttendanceCard({
    required this.title,
    required this.value,
    required this.status,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, size: 28, color: Colors.deepOrange),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 2),
              Text(status, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String date;
  final String time;

  const _ActivityItem({required this.date, required this.time});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.login, color: Colors.deepOrange),
      title: Text("Check In", style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(date),
      trailing: Text(time, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}

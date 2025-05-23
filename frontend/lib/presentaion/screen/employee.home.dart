import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/application/states/attendance.state.dart' as states;
import 'package:staffsync/domain/model/attendance.model.dart';
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

class _EmployeeHomeScreenState extends ConsumerState<EmployeeHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userNotifierProvider.notifier).loadUserFromStorage();
      ref.read(attendanceNotifierProvider.notifier).getAttendances();
    });
  }

  void _handleAttendance() async {
    try {
      final notifier = ref.read(attendanceNotifierProvider.notifier);
      final hasActiveCheckIn = notifier.hasActiveCheckIn();
      
      if (hasActiveCheckIn) {
        // If already checked in, perform check-out
        await notifier.checkOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text('Check-out successful'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Perform check-in
        final attendanceResponse = AttendanceResponse(
          message: 'Checking in...',
          attendance: AttendanceData(
            id: 0, // This will be set by the backend
            checkIn: DateTime.now(),
            attendance: 'PRESENT',
          ),
        );
        await notifier.checkIn(attendanceResponse);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text('Check-in successful'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      // Refresh attendance data
      await notifier.getAttendances();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Operation failed: ${e.toString()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceNotifierProvider);
    final hasActiveCheckIn = ref.watch(attendanceNotifierProvider.notifier).hasActiveCheckIn();
    final todayAttendance = ref.watch(attendanceNotifierProvider.notifier).getTodayAttendance();

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
                  children: [
                    _TodayAttendance(attendanceState: attendanceState),
                    const SizedBox(height: 16),
                    const Text("Today's Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (todayAttendance.isNotEmpty) ...[
                      ...todayAttendance.map((attendance) => [
                        _ActivityItem(
                          date: attendance.date,
                          time: attendance.checkIn,
                          type: 'Check In',
                          status: attendance.attendance,
                        ),
                        if (attendance.checkOut != null)
                          _ActivityItem(
                            date: attendance.date,
                            time: attendance.checkOut!,
                            type: 'Check Out',
                            status: attendance.attendance,
                          ),
                      ]).expand((items) => items),
                    ] else ...[
                      const Center(child: Text('No activity today')),
                    ],
                    const SizedBox(height: 16),
                    const Text("Past Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (attendanceState is states.AttendanceData) ...[
                      ...(attendanceState as states.AttendanceData).attendance
                          .where((a) => a.date.year != DateTime.now().year || 
                                      a.date.month != DateTime.now().month || 
                                      a.date.day != DateTime.now().day)
                          .map((attendance) => _ActivityItem(
                            date: attendance.date,
                            time: attendance.checkIn,
                            type: 'Check In',
                            status: attendance.attendance,
                          )),
                    ] else if (attendanceState is states.AttendanceError) ...[
                      Center(child: Text('Error: ${attendanceState.message}')),
                    ] else ...[
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _handleAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasActiveCheckIn ? Colors.red : Colors.deepOrange,
                  padding: const EdgeInsets.all(24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  hasActiveCheckIn ? "Check Out" : "Check In",
                  style: const TextStyle(fontSize: 16, color: Color.fromRGBO(255, 255, 255, 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

class _TodayAttendance extends ConsumerWidget {
  final states.AttendanceState attendanceState;

  const _TodayAttendance({required this.attendanceState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String checkInTime = "Not checked in";
    String checkOutTime = "Not checked out";
    String breakTime = "No break";
    String totalDays = "0";

    if (attendanceState is states.AttendanceData) {
      final today = DateTime.now();
      final todayAttendance = (attendanceState as states.AttendanceData).attendance
          .where((a) => a.date.year == today.year && 
                        a.date.month == today.month && 
                        a.date.day == today.day)
          .toList();

      if (todayAttendance.isNotEmpty) {
        // Get the latest check-in
        final latestCheckIn = todayAttendance
            .where((a) => a.checkIn != null)
            .reduce((a, b) => a.checkIn.isAfter(b.checkIn) ? a : b);
        
        // Get the latest check-out
        final latestCheckOut = todayAttendance
            .where((a) => a.checkOut != null)
            .reduce((a, b) => a.checkOut!.isAfter(b.checkOut!) ? a : b);

        checkInTime = DateFormat('hh:mm a').format(latestCheckIn.checkIn);
        
        if (latestCheckOut.checkOut != null) {
          checkOutTime = DateFormat('hh:mm a').format(latestCheckOut.checkOut!);
        }
      }

      // Count unique days with attendance
      final uniqueDays = (attendanceState as states.AttendanceData).attendance
          .where((a) => a.attendance == 'PRESENT')
          .map((a) => DateTime(a.date.year, a.date.month, a.date.day))
          .toSet()
          .length;
      
      totalDays = uniqueDays.toString();
    }

    return Column(
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _AttendanceCard(
              title: "Check In",
              value: checkInTime,
              status: checkInTime == "Not checked in" ? "Not Checked In" : "On Time",
              icon: Icons.login,
            ),
            _AttendanceCard(
              title: "Check Out",
              value: checkOutTime,
              status: checkOutTime == "Not checked out" ? "Not Checked Out" : "Checked Out",
              icon: Icons.logout,
            ),
            _AttendanceCard(
              title: "Break Time",
              value: breakTime,
              status: "Break Time",
              icon: Icons.breakfast_dining,
            ),
            _AttendanceCard(
              title: "Total Days",
              value: totalDays,
              status: "Working Days",
              icon: Icons.calendar_today,
            ),
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
  final DateTime date;
  final DateTime time;
  final String type;
  final String status;

  const _ActivityItem({
    required this.date,
    required this.time,
    required this.type,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: type == 'Check In' ? Colors.green : Colors.blue,
          child: Icon(
            type == 'Check In' ? Icons.login : Icons.logout,
            color: Colors.white,
          ),
        ),
        title: Text(type),
        subtitle: Text(
          '${DateFormat('MMM dd, yyyy').format(date)} at ${DateFormat('hh:mm a').format(time)}',
        ),
        
      ),
    );
  }
}

Widget _buildActivityList(List<Attendance> attendances) {
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: attendances.length,
    itemBuilder: (context, index) {
      final attendance = attendances[index];
      return _ActivityItem(
        date: attendance.date,
        time: attendance.checkIn,
        type: 'Check In',
        status: attendance.attendance,
      );
      if (attendance.checkOut != null) {
        return _ActivityItem(
          date: attendance.date,
          time: attendance.checkOut!,
          type: 'Check Out',
          status: attendance.attendance,
        );
      }
    },
  );
}

Widget _buildTodayActivity(List<Attendance> todayAttendance) {
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: todayAttendance.length * 2, // Double for check-in and check-out
    itemBuilder: (context, index) {
      final attendance = todayAttendance[index ~/ 2];
      final isCheckIn = index.isEven;
      
      if (isCheckIn) {
        return _ActivityItem(
          date: attendance.date,
          time: attendance.checkIn,
          type: 'Check In',
          status: attendance.attendance,
        );
      } else if (attendance.checkOut != null) {
        return _ActivityItem(
          date: attendance.date,
          time: attendance.checkOut!,
          type: 'Check Out',
          status: attendance.attendance,
        );
      }
      return const SizedBox.shrink();
    },
  );
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDashboard(states.AttendanceState attendanceState) {
  if (attendanceState is states.AttendanceData) {
    final attendances = attendanceState.attendance;
    final totalDays = attendances.where((a) => a.attendance == 'PRESENT').length;
    final todayAttendance = attendances.where((a) => 
      a.date.year == DateTime.now().year && 
      a.date.month == DateTime.now().month && 
      a.date.day == DateTime.now().day
    ).toList();

    return Column(
      children: [
        _DashboardCard(
          title: 'Total Days',
          value: totalDays.toString(),
          icon: Icons.calendar_today,
        ),
        const SizedBox(height: 16),
        _DashboardCard(
          title: 'Today\'s Status',
          value: todayAttendance.isNotEmpty ? 'Present' : 'Not Checked In',
          icon: Icons.access_time,
        ),
      ],
    );
  }
  return const SizedBox.shrink();
}

Widget _buildTodayAttendance(states.AttendanceState attendanceState) {
  if (attendanceState is states.AttendanceData) {
    final todayAttendance = attendanceState.attendance.where((a) => 
      a.date.year == DateTime.now().year && 
      a.date.month == DateTime.now().month && 
      a.date.day == DateTime.now().day
    ).toList();

    if (todayAttendance.isEmpty) {
      return const Center(
        child: Text(
          'No activity for today',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return _buildTodayActivity(todayAttendance);
  }
  return const SizedBox.shrink();
}

Widget _buildPastActivity(states.AttendanceState attendanceState) {
  if (attendanceState is states.AttendanceData) {
    final pastAttendance = attendanceState.attendance.where((a) => 
      a.date.year != DateTime.now().year || 
      a.date.month != DateTime.now().month || 
      a.date.day != DateTime.now().day
    ).toList();

    if (pastAttendance.isEmpty) {
      return const Center(
        child: Text(
          'No past activity',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return _buildActivityList(pastAttendance);
  }
  return const SizedBox.shrink();
}

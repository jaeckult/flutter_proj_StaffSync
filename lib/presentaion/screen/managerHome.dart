import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/application/states/attendance.state.dart' as states;
import 'package:staffsync/domain/model/attendance.model.dart';
import 'package:intl/intl.dart';
import 'package:staffsync/application/states/manager.state.dart';
import 'package:staffsync/domain/model/managerDashboard.model.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/application/states/leaveDashboard.state.dart';

class ManagerHomeScreen extends ConsumerStatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  ConsumerState<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends ConsumerState<ManagerHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userNotifierProvider.notifier).loadUserFromStorage();
      ref.read(managerDashboardNotifierProvider.notifier).fetchDashboardStats();
      ref.read(leaveNotifierProvider.notifier).getLeaveDashboardStats();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      ref.read(userNotifierProvider.notifier).loadUserFromStorage(),
      ref.read(managerDashboardNotifierProvider.notifier).fetchDashboardStats(),
      ref.read(leaveNotifierProvider.notifier).getLeaveDashboardStats(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final managerDashboardState = ref.watch(managerDashboardNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProfileSection(),
              const _DateSelector(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Attendance Summary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (managerDashboardState is ManagerDashboardLoading) ...[
                        const Center(child: CircularProgressIndicator()),
                      ] else if (managerDashboardState is ManagerDashboardError) ...[
                        Center(
                          child: Text(
                            'Error: ${managerDashboardState.message}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ] else if (managerDashboardState is ManagerDashboardData) ...[
                        _AttendanceSummaryCards(
                          stats: managerDashboardState.stats,
                        ),
                      ] else ...[
                        const Center(child: Text('Load failed or initial state')),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        "Employees Daily Status",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _EmployeesDailyStatusList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSection extends ConsumerWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);
    return ListTile(
      leading: const CircleAvatar(
        radius: 24,
        backgroundImage: AssetImage('assets/profile.png'),
      ),
      title: Text(
        user?.profile.fullName ?? "Loading...",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(user?.profile.designation ?? "Loading..."),
      trailing: IconButton(
        icon: const Icon(Icons.notifications_none),
        onPressed: () => context.push('/notification'),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dates = List.generate(6, (i) => now.add(Duration(days: i)));
    const selectedIndex = 0;

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
            margin: const EdgeInsets.all(12),
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepOrange : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ]
                      : [],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
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
      final todayAttendance =
          (attendanceState as states.AttendanceData).attendance
              .where(
                (a) =>
                    a.date.year == today.year &&
                    a.date.month == today.month &&
                    a.date.day == today.day,
              )
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
      final uniqueDays =
          (attendanceState as states.AttendanceData).attendance
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
              status:
                  checkInTime == "Not checked in"
                      ? "Not Checked In"
                      : "On Time",
              icon: Icons.login,
            ),
            _AttendanceCard(
              title: "Check Out",
              value: checkOutTime,
              status:
                  checkOutTime == "Not checked out"
                      ? "Not Checked Out"
                      : "Checked Out",
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
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                status,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
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
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
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
    final totalDays =
        attendances.where((a) => a.attendance == 'PRESENT').length;
    final todayAttendance =
        attendances
            .where(
              (a) =>
                  a.date.year == DateTime.now().year &&
                  a.date.month == DateTime.now().month &&
                  a.date.day == DateTime.now().day,
            )
            .toList();

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
    final todayAttendance =
        attendanceState.attendance
            .where(
              (a) =>
                  a.date.year == DateTime.now().year &&
                  a.date.month == DateTime.now().month &&
                  a.date.day == DateTime.now().day,
            )
            .toList();

    if (todayAttendance.isEmpty) {
      return const Center(
        child: Text(
          'No activity for today',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return _buildTodayActivity(todayAttendance);
  }
  return const SizedBox.shrink();
}

Widget _buildPastActivity(states.AttendanceState attendanceState) {
  if (attendanceState is states.AttendanceData) {
    final pastAttendance =
        attendanceState.attendance
            .where(
              (a) =>
                  a.date.year != DateTime.now().year ||
                  a.date.month != DateTime.now().month ||
                  a.date.day != DateTime.now().day,
            )
            .toList();

    if (pastAttendance.isEmpty) {
      return const Center(
        child: Text(
          'No past activity',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return _buildActivityList(pastAttendance);
  }
  return const SizedBox.shrink();
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class _AttendanceSummaryCards extends ConsumerWidget {
  final Managerdashboard stats;

  const _AttendanceSummaryCards({required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = 16.0;
    final double spacing = 16.0;
    final double cardWidth =
        (screenWidth - 2 * horizontalPadding - spacing) / 2;

    final leaveDashboardState = ref.watch(leaveNotifierProvider);
    int onLeaveToday = 0;

    if (leaveDashboardState is LeaveDashboardData) {
      // Get the total approved leaves from the first dashboard entry
      // Since the API returns a single dashboard entry for all users
      if (leaveDashboardState.leaveDashboard.isNotEmpty) {
        onLeaveToday = leaveDashboardState.leaveDashboard.first.approved;
      }
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children:
            [
              _SummaryCard(
                title: "Total Check-ins",
                value: "${stats.totalCheckedIn}",
                icon: Icons.login,
                iconColor: Colors.green,
              ),
              _SummaryCard(
                title: "Total Check-outs",
                value: "${stats.totalCheckedOut}",
                icon: Icons.logout,
                iconColor: Colors.red,
              ),
              _SummaryCard(
                title: "On leave today",
                value: "$onLeaveToday",
                icon: Icons.beach_access,
                iconColor: Colors.blue,
              ),
              _SummaryCard(
                title: "On work today",
                value: "${stats.totalPresent}",
                icon: Icons.work,
                iconColor: Colors.orange,
              ),
            ].map((card) => SizedBox(width: cardWidth, child: card)).toList(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}

class _EmployeesDailyStatusList extends ConsumerWidget {
  const _EmployeesDailyStatusList({super.key});

  String getStatus(User employee) {
    final hasAttendance = employee.attendance.isNotEmpty;
    return hasAttendance && employee.attendance.last.checkOut == null
        ? "Checked in"
        : "Checked out";
  }

  Color getStatusColor(String status) {
    return status == 'Checked in' ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(bulkUserNotifierProvider);

    if (employees.isEmpty) {
      Future.microtask(
        () => ref.read(bulkUserNotifierProvider.notifier).getEmployees(),
      );
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: employees.length,
      separatorBuilder:
          (context, index) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final User employee = employees[index];
        final status = getStatus(employee);
        Uint8List? imageBytes;
        try {
          if (employee.profile.profilePicture != null &&
              employee.profile.profilePicture.isNotEmpty) {
            imageBytes = base64Decode(employee.profile.profilePicture);
          }
        } catch (e) {
          imageBytes = null;
        }

        return ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundImage:
                imageBytes != null
                    ? MemoryImage(imageBytes)
                    : const AssetImage('assets/images/profile_placeholder.png')
                        as ImageProvider,
            backgroundColor: Colors.grey[300],
          ),
          title: Text(
            employee.profile.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            employee.profile.designation,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          trailing: Text(
            status,
            style: TextStyle(
              color: getStatusColor(status),
              fontWeight: FontWeight.w500,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        );
      },
    );
  }
}

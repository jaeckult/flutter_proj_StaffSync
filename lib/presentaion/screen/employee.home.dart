import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffsync/application/bloc/attendance/attendance_bloc.dart';
import 'package:staffsync/application/bloc/attendance/attendance_event.dart';
import 'package:staffsync/application/bloc/user/user_cubit.dart';
import 'package:staffsync/application/bloc/attendance/attendance_state.dart' as states;
import 'package:staffsync/domain/model/attendance.model.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:staffsync/presentaion/widgets/shimmer_skeletons.dart';
import 'package:staffsync/utils/timezone_helper.dart';
import 'package:staffsync/presentaion/screen/employee_home/widgets/attendance_card.dart';
import 'package:staffsync/presentaion/screen/employee_home/widgets/profile_section.dart';
import 'package:staffsync/presentaion/screen/employee_home/widgets/date_selector.dart';
import 'package:staffsync/presentaion/screen/employee_home/widgets/activity_item.dart';

void main() => runApp(const EmployeeHomeApp());

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

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserCubit>().loadUserFromStorage();
      context.read<AttendanceBloc>().add(const AttendanceFetchRequested());
    });
  }

  Future<void> _refreshData() async {
    await context.read<UserCubit>().loadUserFromStorage();
    context.read<AttendanceBloc>().add(const AttendanceFetchRequested());
  }

  void _handleAttendance() async {
    try {
      final attendanceState = context.read<AttendanceBloc>().state;
      final today = TimezoneHelper.now();
      final hasActiveCheckIn = attendanceState is states.AttendanceData &&
        attendanceState.attendance.any((a) => a.date.year == today.year && a.date.month == today.month && a.date.day == today.day && a.checkOut == null);

      if (hasActiveCheckIn) {
        context.read<AttendanceBloc>().add(const AttendanceCheckOutRequested());
        if (mounted) {
          Flushbar(
            message: "Check-out successful",
            icon: const Icon(Icons.check_circle, color: Colors.white),
            backgroundColor: const Color.fromARGB(255, 203, 88, 40),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(10),
            flushbarPosition: FlushbarPosition.TOP,
            flushbarStyle: FlushbarStyle.FLOATING,
          ).show(context);
        }
      } else {
        // Perform check-in
        final attendanceResponse = AttendanceResponse(
          message: 'Checking in...',
          attendance: AttendanceData(
            id: 0,
            checkIn: TimezoneHelper.now(),
            attendance: 'PRESENT',
            checkOut: null,
          ),
        );
        context.read<AttendanceBloc>().add(AttendanceCheckInRequested(attendanceResponse));
        if (mounted) {
          Flushbar(
            message: "Check-in successful",
            icon: const Icon(Icons.check_circle, color: Colors.white),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(10),
            flushbarPosition: FlushbarPosition.TOP,
            flushbarStyle: FlushbarStyle.FLOATING,
          ).show(context);
        }
      }

      context.read<AttendanceBloc>().add(const AttendanceFetchRequested(showLoading: false));
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
    final attendanceState = context.watch<AttendanceBloc>().state;
    final today = TimezoneHelper.now();
    List<Attendance> todayAttendance;
    if (attendanceState is states.AttendanceData) {
      todayAttendance = attendanceState.attendance
          .where((a) => a.date.year == today.year && a.date.month == today.month && a.date.day == today.day)
          .toList();
    } else {
      todayAttendance = <Attendance>[];
    }
    final hasActiveCheckIn = attendanceState is states.AttendanceData &&
        todayAttendance.any((a) => a.checkOut == null);
    final isCheckingIn = attendanceState is states.AttendanceData &&
                         attendanceState.isCheckingIn;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              const ProfileSection(),
              const DateSelector(),
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
                      _TodayAttendance(attendanceState: attendanceState),
                      const SizedBox(height: 16),
                      const Text(
                        "Today's Activity",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (todayAttendance.isNotEmpty) ...[
                        ...todayAttendance
                            .map<List<Widget>>((attendance) => [
                                  ActivityItem(
                                    date: attendance.date,
                                    time: attendance.checkIn,
                                    type: 'Check In',
                                    status: attendance.attendance,
                                    id: attendance.id,
                                    onDelete: () => _confirmDeleteAttendance(context, attendance.id),
                                  ),
                                  if (attendance.checkOut != null)
                                    ActivityItem(
                                      date: attendance.date,
                                      time: attendance.checkOut!,
                                      type: 'Check Out',
                                      status: attendance.attendance,
                                      id: attendance.id,
                                      onDelete: () => _confirmDeleteAttendance(context, attendance.id),
                                    ),
                                ])
                            .expand((items) => items)
                            .toList(),
                      ] else ...[
                        const Center(child: Text('No activity today')),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        "Past Activity",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (attendanceState is states.AttendanceData) ...[
                        ...(attendanceState).attendance
                            .where(
                              (a) {
                                final today = TimezoneHelper.now();
                                return a.date.year != today.year ||
                                       a.date.month != today.month ||
                                       a.date.day != today.day;
                              },
                            )
                            .map(
                              (attendance) => ActivityItem(
                                date: attendance.date,
                                time: attendance.checkIn,
                                type: 'Check In',
                                status: attendance.attendance,
                                id: attendance.id,
                                onDelete: () => _confirmDeleteAttendance(context, attendance.id),
                              ),
                            ),
                      ] else if (attendanceState is states.AttendanceError) ...[
                        Center(child: Text('Error: ${attendanceState.message}')),
                      ] else ...[
                        const ShimmerList(itemCount: 6),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCheckingIn ? null : _handleAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          hasActiveCheckIn
                              ? Colors.red
                              : const Color.fromARGB(255, 58, 168, 62),
                      padding: const EdgeInsets.all(18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isCheckingIn
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            hasActiveCheckIn ? "Check Out" : "Check In",
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
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

// extracted: _ProfileSection and _DateSelector moved to
// `presentaion/screen/employee_home/widgets/profile_section.dart`
// and `presentaion/screen/employee_home/widgets/date_selector.dart`

class _TodayAttendance extends StatelessWidget {
  final states.AttendanceState attendanceState;

  const _TodayAttendance({required this.attendanceState});

  @override
  Widget build(BuildContext context) {
    if (attendanceState is! states.AttendanceData) {
      return const ShimmerCardGrid(count: 4);
    }
    String checkInTime = "Not checked in";
    String checkOutTime = "Not checked out";
    String breakTime = "No break";
    String totalDays = "0";

    if (attendanceState is states.AttendanceData) {
      final today = TimezoneHelper.now();
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
        final checkIns = todayAttendance;
        if (checkIns.isNotEmpty) {
          final latestCheckIn = checkIns.reduce(
            (a, b) => a.checkIn.isAfter(b.checkIn) ? a : b,
          );
          checkInTime = DateFormat('hh:mm a').format(latestCheckIn.checkIn);
        }

        // Get the latest check-out
        final checkOuts = todayAttendance.where((a) => a.checkOut != null).toList();
        if (checkOuts.isNotEmpty) {
          final latestCheckOut = checkOuts.reduce(
            (a, b) => a.checkOut!.isAfter(b.checkOut!) ? a : b,
          );
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
            AttendanceCard(
              title: "Check In",
              value: checkInTime,
              status:
              checkInTime == "Not checked in"
                  ? "Not Checked In"
                  : "On Time",
              icon: Icons.login,
            ),
            AttendanceCard(
              title: "Check Out",
              value: checkOutTime,
              status:
              checkOutTime == "Not checked out"
                  ? "Not Checked Out"
                  : "Checked Out",
              icon: Icons.logout,
            ),
            AttendanceCard(
              title: "Break Time",
              value: breakTime,
              status: "Break Time",
              icon: Icons.breakfast_dining,
            ),
            AttendanceCard(
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

// moved to: presentaion/screen/employee_home/widgets/attendance_card.dart

void _confirmDeleteAttendance(BuildContext context, int id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Attendance Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AttendanceBloc>().add(AttendanceDeleteRequested(id));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

Widget _buildActivityList(List<Attendance> attendances) {
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: attendances.length,
    itemBuilder: (context, index) {
      final attendance = attendances[index];
      return ActivityItem(
        date: attendance.date,
        time: attendance.checkIn,
        type: 'Check In',
        status: attendance.attendance,
        id: attendance.id,
        onDelete: () => _confirmDeleteAttendance(context, attendance.id),
      );
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
        return ActivityItem(
          date: attendance.date,
          time: attendance.checkIn,
          type: 'Check In',
          status: attendance.attendance,
          id: attendance.id,
          onDelete: () => _confirmDeleteAttendance(context, attendance.id),
        );
      } else if (attendance.checkOut != null) {
        return ActivityItem(
          date: attendance.date,
          time: attendance.checkOut!,
          type: 'Check Out',
          status: attendance.attendance,
          id: attendance.id,
          onDelete: () => _confirmDeleteAttendance(context, attendance.id),
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
    final today = TimezoneHelper.now();
    final todayAttendance =
    attendances
        .where(
          (a) =>
      a.date.year == today.year &&
          a.date.month == today.month &&
          a.date.day == today.day,
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
    final today = TimezoneHelper.now();
    final todayAttendance =
    attendanceState.attendance
        .where(
          (a) =>
      a.date.year == today.year &&
          a.date.month == today.month &&
          a.date.day == today.day,
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
    final today = TimezoneHelper.now();
    final pastAttendance =
    attendanceState.attendance
        .where(
          (a) =>
      a.date.year != today.year ||
          a.date.month != today.month ||
          a.date.day != today.day,
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
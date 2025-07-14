import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffsync/application/bloc/bulk_user/bulk_user_cubit.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/presentaion/widgets/profile_picture_widget.dart';

Color getStatusColor(String status) {
  return status == 'Checked in' ? Colors.green : Colors.red;
}

class ManagerListScreen extends StatefulWidget {
  const ManagerListScreen({super.key}); 
  @override
  State<ManagerListScreen> createState() => _EmployeeListStateScreen();
}

class _EmployeeListStateScreen extends State<ManagerListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BulkUserCubit>().getEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Employee List',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<BulkUserCubit, List<User>>(
                  builder: (context, employees) {
                    if (employees.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.separated(
                      itemCount: employees.length,
                      separatorBuilder: (context, index) => const Divider(height: 20),
                      itemBuilder: (context, index) {
                        final User employee = employees[index];
                        final hasAttendance = employee.attendance.isNotEmpty;
                        final status = hasAttendance && employee.attendance.last.checkOut == null ? "Checked in" : "Checked out";
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ProfilePictureWidget(
                              profilePicture: employee.profile.profilePicture,
                              radius: 25,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employee.profile.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    employee.profile.designation,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              status,
                              style: TextStyle(
                                color: getStatusColor(status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(context, employee.id),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<BulkUserCubit>().deleteEmployee(userId);
        await context.read<BulkUserCubit>().getEmployees();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete employee: ${e.toString()}')),
          );
        }
      }
    }
  }
}

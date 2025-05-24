import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/domain/model/user.model.dart';


void main() {
  runApp(const MyApp());
}
  Color getStatusColor(String status) {
    return status == 'Checked in' ? Colors.green : Colors.red;
  }
  

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee List',
      home: const EmployeeListScreen(),
    );
  }
}

class EmployeeListScreen extends ConsumerStatefulWidget {
  const EmployeeListScreen({super.key});
   @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmployeeListStateScreen();

  
}
class _EmployeeListStateScreen extends ConsumerState<EmployeeListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
     ref.read(bulkUserNotifierProvider.notifier).getEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(bulkUserNotifierProvider);
    
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
                child: employees.isEmpty
                    ? const Center(child: CircularProgressIndicator()):
                ListView.separated(
                  itemCount: employees.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 20),
                  itemBuilder: (context, index) {
                    final User employee = employees[index];;
                    final hasAttendance = employee.attendance.isNotEmpty;
                    final status = hasAttendance && employee.attendance.last.checkOut == null ? "Checked in": "Checked out";
                    final photoUrl = employee.profile.profilePicture;   
                  
                    Uint8List imageBytes = base64Decode(photoUrl);   

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
      
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: MemoryImage(imageBytes)
                          
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                 employee.profile.fullName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                employee.profile.designation,
                                style: TextStyle(
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
                      ],
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
  
 
}

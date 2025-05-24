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
      title: 'Employee Holiday',
      home: const EmployeeHolidayScreen(),
    );
  }
}

class EmployeeHolidayScreen extends ConsumerStatefulWidget {
  const EmployeeHolidayScreen({super.key});
   @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmployeeHolidayStateScreen();

  
}
class _EmployeeHolidayStateScreen extends ConsumerState<EmployeeHolidayScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
     ref.read(bulkUserNotifierProvider.notifier).getEmployees();
    });
  }

  bool _isLoading = false;


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
                'Employee Holiday',
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
                    final status = "Checked-in";
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('assets/avatar.jpg'),
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

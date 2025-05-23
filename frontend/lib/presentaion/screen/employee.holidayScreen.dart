import 'package:flutter/material.dart';

class EmployeeHolidayScreen extends StatelessWidget {
  const EmployeeHolidayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          'Employee Holiday Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

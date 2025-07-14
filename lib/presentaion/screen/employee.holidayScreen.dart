import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:staffsync/application/bloc/holiday/holiday_bloc.dart';
import 'package:staffsync/application/bloc/holiday/holiday_state.dart';
import 'package:staffsync/domain/model/holiday.model.dart';

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
    return const MaterialApp(
      title: 'Employee Holiday',
      home: EmployeeHolidayScreen(),
    );
  }
}

class EmployeeHolidayScreen extends StatefulWidget {
  const EmployeeHolidayScreen({super.key});

  @override
  State<EmployeeHolidayScreen> createState() => _EmployeeHolidayStateScreen();
}

class _EmployeeHolidayStateScreen extends State<EmployeeHolidayScreen> {
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('MMM d, yyyy');
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Employee Holiday',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<HolidayBloc, HolidayState>(
                    builder: (context, state) {
                      if (state is HolidayLoading || state is HolidayInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is HolidayError) {
                        return Center(child: Text(state.message));
                      }
                      if (state is HolidayLoaded) {
                        final holidays = state.holidays;
                        if (holidays.isEmpty) {
                          return const Center(child: Text('No holidays found'));
                        }
                        return ListView.separated(
                          itemCount: holidays.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final Holiday holiday = holidays[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.beach_access,
                                        color: Colors.deepOrange, size: 30),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            holiday.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          if (holiday.description != null && holiday.description!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                holiday.description!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${dateFormatter.format(holiday.startDate)} → ${dateFormatter.format(holiday.endDate)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
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
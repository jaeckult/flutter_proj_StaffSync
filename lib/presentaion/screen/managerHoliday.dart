import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/domain/model/holiday.model.dart';
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
    return const MaterialApp(
      title: 'Employee Holiday',
      home: ManagerHolidayScreen(),
    );
  }
}

class ManagerHolidayScreen extends ConsumerStatefulWidget {
  const ManagerHolidayScreen({super.key});
   @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ManagerHolidayStateScreen();

  
}
class _ManagerHolidayStateScreen extends ConsumerState<ManagerHolidayScreen> {
  final DateFormat dateFormatter = DateFormat('MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
     ref.read(holidayNotifierProvider.notifier).getHolidayList();
    });
  }

  final bool _isLoading = false;


  @override
  Widget build(BuildContext context) {
    final holidays = ref.watch(holidayNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHolidayDialog(context),
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(bottom: 12),child:
              Text(
                'Employee Holiday',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),),
              
              const SizedBox(height: 12),
              Expanded(
                child: holidays.isEmpty
                    ? const Center(child: CircularProgressIndicator()):
                ListView.separated(
                itemCount: holidays.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
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
                                Padding(padding: const EdgeInsets.only(top: 4.0),
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
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _showAddHolidayDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Holiday'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Holiday Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(startDate == null ? 'Select date' : dateFormatter.format(startDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    startDate = date;
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(endDate == null ? 'Select date' : dateFormatter.format(endDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: startDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    endDate = date;
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isEmpty || startDate == null || endDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final holiday = Holiday(
          id: 0, // This will be set by the backend
          title: titleController.text,
          startDate: startDate!,
          endDate: endDate!,
          description: descriptionController.text.isEmpty ? null : descriptionController.text,
        );

        await ref.read(holidayNotifierProvider.notifier).addHoliday(holiday);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Holiday added successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add holiday: ${e.toString()}')),
          );
        }
      }
    }
  }
}

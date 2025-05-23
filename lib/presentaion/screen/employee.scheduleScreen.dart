import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/notifiers/leaveDashboard.notifier.dart';
import 'package:staffsync/application/notifiers/leaveRequest.notifiers.dart';
import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/application/states/leaveDashboard.state.dart';
import 'package:staffsync/application/states/leaveRequest.state.dart';
import 'package:staffsync/domain/model/leaveRequest.model.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveNotifierProvider.notifier).getLeaveDashboardStats();
    });
  }

  void _showLeaveRequestForm() {
    showDialog(
      context: context,
      builder: (context) => const LeaveRequestForm(),
    );
  }

  Widget leaveCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leaveState = ref.watch(leaveNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded),
            onPressed: _showLeaveRequestForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: switch (leaveState) {
          LeaveDashboardLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          LeaveDashboardError(message: final error) => Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          LeaveDashboardData(leaveDashboard: final data) =>
            data.isEmpty
                ? const Center(child: Text('No data available'))
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Leave Summary',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        leaveCard(
                          'Leave Balance',
                          data.first.balance.toString(),
                        ),
                        leaveCard(
                          'Leave Approved',
                          data.first.approved.toString(),
                        ),
                        leaveCard(
                          'Leave Pending',
                          data.first.pending.toString(),
                        ),
                        leaveCard(
                          'Leave Cancelled',
                          data.first.cancelled.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 10),
                    const Expanded(child: LeaveTab()),
                  ],
                ),
        },
      ),
    );
  }
}

class LeaveTab extends ConsumerStatefulWidget {
  const LeaveTab({super.key});

  @override
  ConsumerState<LeaveTab> createState() => _LeaveTabState();
}

class _LeaveTabState extends ConsumerState<LeaveTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveRequestNotifierProvider.notifier).getLeaveRequests();
    });
  }

  Widget _buildLeaveRequestCard(LeaveRequest request) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text('${request.type} Leave'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${request.startDate.toString().split(' ')[0]}'),
            Text('To: ${request.endDate.toString().split(' ')[0]}'),
            Text('Status: ${request.status}'),
            Text('Approved by: ${request.approvedById ?? ""} '),
          ],
        ),
        trailing: Chip(
          label: Text(request.status),
          backgroundColor:
              request.status == 'APPROVED'
                  ? Colors.green
                  : request.status == 'PENDING'
                  ? Colors.orange
                  : Colors.red,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leaveRequestState = ref.watch(leaveRequestNotifierProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.history), text: 'Past'),
              Tab(icon: Icon(Icons.pending), text: 'Pending'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Past Tab
                switch (leaveRequestState) {
                  LeaveRequestLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  LeaveRequestError(message: final error) => Center(
                    child: Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  LeaveRequestData(leaveRequest: final requests) =>
                    ListView.builder(
                      itemCount:
                          requests.where((r) => r.status != 'PENDING').length,
                      itemBuilder: (context, index) {
                        final pastRequests =
                            requests
                                .where((r) => r.status != 'PENDING')
                                .toList();
                        return _buildLeaveRequestCard(pastRequests[index]);
                      },
                    ),
                },
                // Pending Tab
                switch (leaveRequestState) {
                  LeaveRequestLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  LeaveRequestError(message: final error) => Center(
                    child: Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  LeaveRequestData(leaveRequest: final requests) =>
                    ListView.builder(
                      itemCount:
                          requests.where((r) => r.status == 'PENDING').length,
                      itemBuilder: (context, index) {
                        final pendingRequests =
                            requests
                                .where((r) => r.status == 'PENDING')
                                .toList();
                        return _buildLeaveRequestCard(pendingRequests[index]);
                      },
                    ),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LeaveRequestForm extends ConsumerStatefulWidget {
  const LeaveRequestForm({super.key});

  @override
  ConsumerState<LeaveRequestForm> createState() => _LeaveRequestFormState();
}

class _LeaveRequestFormState extends ConsumerState<LeaveRequestForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'SICK';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(leaveRequestNotifierProvider.notifier).addLeaveRequests(
          type: _selectedType,
          startDate: _startDate,
          endDate: _endDate,
          reason: _reasonController.text,
        );
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Leave request submitted successfully')),
          );
          // Refresh the leave requests list
          ref.read(leaveRequestNotifierProvider.notifier).getLeaveRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request Leave'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Leave Type',
                  border: OutlineInputBorder(),
                ),
                items: ['SICK', 'VACATION', 'PERSONAL'].map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a leave type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(_startDate.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(_endDate.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a reason';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

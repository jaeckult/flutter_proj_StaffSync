import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/notifiers/leaveDashboard.notifier.dart';
import 'package:staffsync/application/notifiers/leaveRequest.notifiers.dart';
import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/application/states/leaveDashboard.state.dart';
import 'package:staffsync/application/states/leaveRequest.state.dart';
import 'package:staffsync/domain/model/leaveRequest.model.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

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

  void _refreshDashboard() {
    ref.read(leaveNotifierProvider.notifier).getLeaveDashboardStats();
  }

  Widget leaveCard({
    required String title,
    required String value,
    required Color borderColor,
    required Color backgroundColor,
    required Color valueColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leaveState = ref.watch(leaveNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.all(15.0),
        title: const Text(
          'Leave Dashboard',
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 214, 101, 66),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded),
            onPressed: _showLeaveRequestForm,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshDashboard();
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
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
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              leaveCard(
                                title: 'Leave Balance',
                                value: data.first.balance.toString(),
                                borderColor: Colors.blue.shade100,
                                backgroundColor: Colors.blue.shade50,
                                valueColor: Colors.blue,
                              ),
                              leaveCard(
                                title: 'Leave Approved',
                                value: data.first.approved.toString(),
                                borderColor: Colors.green.shade100,
                                backgroundColor: Colors.green.shade50,
                                valueColor: Colors.green,
                              ),
                              leaveCard(
                                title: 'Leave Pending',
                                value: data.first.pending.toString(),
                                borderColor: Colors.teal.shade100,
                                backgroundColor: Colors.teal.shade50,
                                valueColor: Colors.teal,
                              ),
                              leaveCard(
                                title: 'Leave Cancelled',
                                value: data.first.cancelled.toString(),
                                borderColor: Colors.red.shade100,
                                backgroundColor: Colors.red.shade50,
                                valueColor: Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Divider(),
                          const SizedBox(height: 10),
                          const LeaveTab(),
                        ],
                      ),
                    ),
          },
        ),
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

  void _refreshLeaveRequests() {
    ref.read(leaveRequestNotifierProvider.notifier).getLeaveRequests();
  }

  Widget _buildLeaveRequestCard(LeaveRequest request) {
    Color statusColor;
    switch (request.status.toUpperCase()) {
      case 'APPROVED':
        statusColor = Colors.green;
        break;
      case 'PENDING':
        statusColor = Colors.orange;
        break;
      case 'REJECTED':
      case 'CANCELLED':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Date + Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24, thickness: 1),
          
        ],
      ),
    );
  }

  // Helper widget for the bottom row
  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // Format date (e.g., Apr 15, 2025)
  String _formatDate(DateTime date) {
    return '${_monthAbbr(date.month)} ${date.day}, ${date.year}';
  }

  String _monthAbbr(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
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
        await ref
            .read(leaveRequestNotifierProvider.notifier)
            .addLeaveRequests(
              type: _selectedType,
              startDate: _startDate,
              endDate: _endDate,
              reason: _reasonController.text,
            );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Leave request submitted successfully'),
            ),
          );
          // Refresh the leave requests list
          ref.read(leaveRequestNotifierProvider.notifier).getLeaveRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
                items:
                    ['SICK', 'VACATION', 'PERSONAL'].map((String type) {
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
        ElevatedButton(onPressed: _submitForm, child: const Text('Submit')),
      ],
    );
  }
}

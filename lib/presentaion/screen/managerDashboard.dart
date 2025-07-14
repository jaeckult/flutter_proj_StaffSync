import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffsync/application/bloc/manager_dashboard/manager_dashboard_bloc.dart';
import 'package:staffsync/application/bloc/manager_dashboard/manager_dashboard_event.dart';
import 'package:staffsync/application/bloc/leave_request/leave_request_bloc.dart';
import 'package:staffsync/application/bloc/leave_request/leave_request_event.dart';
import 'package:staffsync/application/bloc/leave_request/leave_request_state.dart';
import 'package:staffsync/domain/model/leaveRequest.model.dart';

class ManagerScheduleScreen extends StatefulWidget {
  const ManagerScheduleScreen({super.key});

  @override
  State<ManagerScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ManagerScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerDashboardBloc>().add(const ManagerDashboardFetchRequested());
      context.read<LeaveRequestBloc>().add(const LeaveRequestFetchRequested());
    });
  }

  Widget _buildLeaveStatsCard(String title, String value, Color color) {
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = context.watch<ManagerDashboardBloc>().state;
    final leaveRequestState = context.watch<LeaveRequestBloc>().state;

    int approvedCount = 0;
    int pendingCount = 0;
    int rejectedCount = 0;

    if (leaveRequestState is LeaveRequestData) {
      final requests = leaveRequestState.leaveRequest;
      approvedCount = requests.where((r) => r.status == 'APPROVED').length;
      pendingCount = requests.where((r) => r.status == 'PENDING').length;
      rejectedCount = requests.where((r) => r.status == 'REJECTED').length;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manager Dashboard')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Leave Request Summary',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildLeaveStatsCard(
                            'Approved',
                            approvedCount.toString(),
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildLeaveStatsCard(
                            'Pending',
                            pendingCount.toString(),
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: _buildLeaveStatsCard(
                          'Rejected',
                          rejectedCount.toString(),
                          Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Leave Requests',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: LeaveTab(leaveRequestState: leaveRequestState),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LeaveTab extends StatefulWidget {
  final LeaveRequestState leaveRequestState;
  const LeaveTab({super.key, required this.leaveRequestState});

  @override
  State<LeaveTab> createState() => _LeaveTabState();
}

class _LeaveTabState extends State<LeaveTab> {
  @override
  Widget build(BuildContext context) {
    final leaveRequestState = widget.leaveRequestState;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [Tab(text: 'Past Requests'), Tab(text: 'Pending Requests')],
          ),
          Expanded(
            child: TabBarView(
              children: [
                switch (leaveRequestState) {
                  LeaveRequestLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  LeaveRequestError(message: final error) => Center(
                    child: Text(
                      'Error fetching leave requests: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  LeaveRequestData(leaveRequest: final requests) =>
                    (() {
                      final pastRequests =
                          requests.where((r) => r.status != 'PENDING').toList();

                      return pastRequests.isEmpty
                          ? const Center(child: Text('No past leave requests'))
                          : ListView.builder(
                            itemCount: pastRequests.length,
                            itemBuilder: (context, index) {
                              return _buildLeaveRequestCard(
                                pastRequests[index],
                              );
                            },
                          );
                    })(),
                  _ => const Center(child: Text('Loading past requests...')),
                },
                switch (leaveRequestState) {
                  LeaveRequestLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  LeaveRequestError(message: final error) => Center(
                    child: Text(
                      'Error fetching leave requests: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  LeaveRequestData(leaveRequest: final requests) =>
                    (() {
                      final pendingRequests =
                          requests.where((r) => r.status == 'PENDING').toList();

                      return pendingRequests.isEmpty
                          ? const Center(
                            child: Text('No pending leave requests'),
                          )
                          : ListView.builder(
                            itemCount: pendingRequests.length,
                            itemBuilder: (context, index) {
                              return _buildLeaveRequestCard(
                                pendingRequests[index],
                              );
                            },
                          );
                    })(),
                  _ => const Center(child: Text('Loading pending requests...')),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestCard(LeaveRequest request) {
    final isPending = request.status == 'PENDING';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: ListTile(
        title: Text('${request.type} Leave'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${request.startDate.toString().split(' ')[0]}'),
            Text('To: ${request.endDate.toString().split(' ')[0]}'),
            Text('Status: ${request.status}'),
            if (request.approvedById != null)
              Text('Approved by: ${request.approvedById}'),
          ],
        ),
        trailing:
            isPending
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        context.read<LeaveRequestBloc>().add(LeaveRequestUpdateRequested(request.id, 'APPROVED'));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        context.read<LeaveRequestBloc>().add(LeaveRequestUpdateRequested(request.id, 'REJECTED'));
                      },
                    ),
                  ],
                )
                : Chip(
                  label: Text(request.status),
                  backgroundColor:
                      request.status == 'APPROVED'
                          ? Colors.green
                          : request.status == 'CANCELLED'
                          ? Colors.red
                          : Colors.orange,
                ),
      ),
    );
  }
}

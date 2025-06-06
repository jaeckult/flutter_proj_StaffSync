import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/notifiers/leaveRequest.notifiers.dart';
import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/application/states/leaveRequest.state.dart';
import 'package:staffsync/application/states/manager.state.dart';
import 'package:staffsync/domain/model/leaveRequest.model.dart';
import 'package:staffsync/domain/model/managerDashboard.model.dart';

class ManagerScheduleScreen extends ConsumerStatefulWidget {
  const ManagerScheduleScreen({super.key});

  @override
  ConsumerState<ManagerScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ManagerScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(managerDashboardNotifierProvider.notifier).fetchDashboardStats();
      ref.read(leaveRequestNotifierProvider.notifier).getLeaveRequests();
    });
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
    final dashboardState = ref.watch(managerDashboardNotifierProvider);
    final leaveRequestState = ref.watch(leaveRequestNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Summary',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            switch (dashboardState) {
              ManagerDashboardLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              ManagerDashboardError(message: final error) => Center(
                child: Text(
                  'Error fetching attendance stats: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              ManagerDashboardData(stats: final data) =>
                data == null
                    ? const Center(child: Text('No attendance data available'))
                    : GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        leaveCard(
                          'Total Present',
                          data.totalPresent.toString(),
                        ),
                        leaveCard(
                          'Total Absent',
                          data.totalAbsent.toString(),
                        ),
                      ],
                    ),
              _ => const Center(child: Text('Loading Attendance Data...')),
            },
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Leave Requests',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(child: LeaveTab(leaveRequestState: leaveRequestState)),
          ],
        ),
      ),
    );
  }
}

class LeaveTab extends ConsumerStatefulWidget {
  final LeaveRequestState leaveRequestState;
  const LeaveTab({super.key, required this.leaveRequestState});

  @override
  ConsumerState<LeaveTab> createState() => _LeaveTabState();
}

class _LeaveTabState extends ConsumerState<LeaveTab> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildLeaveRequestCard(LeaveRequest request) {
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
    final leaveRequestState = widget.leaveRequestState;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Past Requests'),
              Tab(text: 'Pending Requests'),
            ],
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
                    requests.where((r) => r.status != 'PENDING').isEmpty
                         ? const Center(child: Text('No past leave requests'))
                         : ListView.builder(
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
                    requests.where((r) => r.status == 'PENDING').isEmpty
                        ? const Center(child: Text('No pending leave requests'))
                        : ListView.builder(
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
                   _ => const Center(child: Text('Loading pending requests...')),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }
}

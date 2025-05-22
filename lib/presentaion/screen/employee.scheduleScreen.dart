import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/notifiers/leaveDashboard.notifier.dart';
import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/application/states/leaveDashboard.state.dart';

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

  Widget leaveCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
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
      appBar: AppBar(title: const Text('Leave Dashboard')),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: switch (leaveState) {
          LeaveDashboardLoading() => const Center(child: CircularProgressIndicator()),
          LeaveDashboardError(message: final error) => Center(
              child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
            ),
          LeaveDashboardData(leaveDashboard: final data) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 400,
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      leaveCard('Leave Balance', data.first.balance.toString()),
                      leaveCard('Leave Approved', data.first.approved.toString()),
                      leaveCard('Leave Pending', data.first.pending.toString()),
                      leaveCard('Leave Cancelled', data.first.cancelled.toString()),
                    ],
                  ),
                ),
              ),
            ),
        },
      ),
    );
  }
}

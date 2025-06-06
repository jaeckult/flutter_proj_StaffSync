import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/states/manager.state.dart';
import 'package:staffsync/domain/repositories/managerDashboard.repository.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';

class ManagerDashboardNotifier extends StateNotifier<ManagerDashboardState> {
  final AuthRepository _authRepository;
  final ManagerdashboardRepository _managerDashboardRepository;

  ManagerDashboardNotifier(this._authRepository, this._managerDashboardRepository) : super(ManagerDashboardInitial());

  Future<void> fetchDashboardStats() async {
    try {
      state = ManagerDashboardLoading();
      final token = await _authRepository.getToken();
      if (token == null) {
        state = ManagerDashboardError('Authentication token not found');
        return;
      }
      // Assuming getManagerDashboardStats returns a List with one item, as per remote datasource impl
      final statsList = await _managerDashboardRepository.getManagerDashboardStats(token);
      if (statsList.isNotEmpty) {
        state = ManagerDashboardData(statsList.first);
      } else {
        state = ManagerDashboardError('No dashboard stats found');
      }
    } catch (e) {
      state = ManagerDashboardError('Failed to fetch dashboard stats: ${e.toString()}');
    }
  }
}

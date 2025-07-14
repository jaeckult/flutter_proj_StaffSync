import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffsync/application/bloc/manager_dashboard/manager_dashboard_event.dart';
import 'package:staffsync/application/bloc/manager_dashboard/manager_dashboard_state.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/managerDashboard.repository.dart';

class ManagerDashboardBloc extends Bloc<ManagerDashboardEvent, ManagerDashboardState> {
  final AuthRepository authRepository;
  final ManagerdashboardRepository managerDashboardRepository;

  ManagerDashboardBloc({required this.authRepository, required this.managerDashboardRepository})
      : super(ManagerDashboardInitial()) {
    on<ManagerDashboardFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(ManagerDashboardFetchRequested event, Emitter<ManagerDashboardState> emit) async {
    try {
      emit(ManagerDashboardLoading());
      final token = await authRepository.getToken();
      if (token == null) {
        emit(ManagerDashboardError('Authentication token not found'));
        return;
      }
      final statsList = await managerDashboardRepository.getManagerDashboardStats(token);
      if (statsList.isNotEmpty) {
        emit(ManagerDashboardData(statsList.first));
      } else {
        emit(ManagerDashboardError('No dashboard stats found'));
      }
    } catch (e) {
      emit(ManagerDashboardError('Failed to fetch dashboard stats: ${e.toString()}'));
    }
  }
}

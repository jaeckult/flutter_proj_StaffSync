import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffsync/application/bloc/leave_dashboard/leave_dashboard_event.dart';
import 'package:staffsync/application/bloc/leave_dashboard/leave_dashboard_state.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/leaveDashboard.repository.dart';

class LeaveDashboardBloc extends Bloc<LeaveDashboardEvent, LeaveDashboardState> {
  final AuthRepository authRepository;
  final LeaveDashboardRepository leaveDashboardRepository;

  LeaveDashboardBloc({required this.authRepository, required this.leaveDashboardRepository})
      : super(const LeaveDashboardLoading()) {
    on<LeaveDashboardFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(LeaveDashboardFetchRequested event, Emitter<LeaveDashboardState> emit) async {
    try {
      emit(const LeaveDashboardLoading());
      final token = await authRepository.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Token is missing");
      }
      final stats = await leaveDashboardRepository.getLeaveDashboardStats(token);
      emit(LeaveDashboardData(stats));
    } catch (error) {
      emit(LeaveDashboardError(error.toString()));
    }
  }
}

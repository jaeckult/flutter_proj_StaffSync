import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/leaveDashboard.repository.dart';
import 'package:staffsync/application/states/leaveDashboard.state.dart';

class LeaveDashboardNotifier extends StateNotifier<LeaveDashboardState> {
    final AuthRepository authRepository;
    final LeaveDashboardRepository leaveDashboardRepository;
    
    LeaveDashboardNotifier(this.authRepository, this.leaveDashboardRepository) 
        : super(const LeaveDashboardLoading());

    Future<void> getLeaveDashboardStats() async {
    try {
      state = const LeaveDashboardLoading();
      final token = await authRepository.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token is missing");
      }

      final stats = await leaveDashboardRepository.getLeaveDashboardStats(token);
      state = LeaveDashboardData(stats);
    } catch (error) {
      print("Leave dashboard error: $error");
      state = LeaveDashboardError(error.toString());
    }
  }
}
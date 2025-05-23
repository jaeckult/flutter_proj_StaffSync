import 'package:staffsync/domain/model/leaveDashboard.model.dart';

sealed class LeaveDashboardState {
  const LeaveDashboardState();
}

class LeaveDashboardLoading extends LeaveDashboardState {
  const LeaveDashboardLoading();
}

class LeaveDashboardData extends LeaveDashboardState {
  final List<LeaveDashboard> leaveDashboard;
  const LeaveDashboardData(this.leaveDashboard);
}

class LeaveDashboardError extends LeaveDashboardState {
  final String message;
  const LeaveDashboardError(this.message);
}
import 'package:equatable/equatable.dart';
import 'package:staffsync/domain/model/leaveDashboard.model.dart';

abstract class LeaveDashboardState extends Equatable {
  const LeaveDashboardState();

  @override
  List<Object?> get props => [];
}

class LeaveDashboardLoading extends LeaveDashboardState {
  const LeaveDashboardLoading();
}

class LeaveDashboardError extends LeaveDashboardState {
  final String message;
  const LeaveDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

class LeaveDashboardData extends LeaveDashboardState {
  final List<LeaveDashboard> leaveDashboard;
  const LeaveDashboardData(this.leaveDashboard);

  @override
  List<Object?> get props => [leaveDashboard];
}

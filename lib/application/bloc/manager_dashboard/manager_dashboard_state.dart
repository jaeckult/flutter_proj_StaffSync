import 'package:equatable/equatable.dart';
import 'package:staffsync/domain/model/managerDashboard.model.dart';

abstract class ManagerDashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ManagerDashboardInitial extends ManagerDashboardState {}

class ManagerDashboardLoading extends ManagerDashboardState {}

class ManagerDashboardError extends ManagerDashboardState {
  final String message;
  ManagerDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

class ManagerDashboardData extends ManagerDashboardState {
  final Managerdashboard stats;
  ManagerDashboardData(this.stats);

  @override
  List<Object?> get props => [stats];
}

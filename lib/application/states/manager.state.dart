import 'package:staffsync/domain/model/managerDashboard.model.dart';

abstract class ManagerDashboardState {}

class ManagerDashboardInitial extends ManagerDashboardState {}

class ManagerDashboardLoading extends ManagerDashboardState {}

class ManagerDashboardData extends ManagerDashboardState {
  final Managerdashboard stats;

  ManagerDashboardData(this.stats);
}

class ManagerDashboardError extends ManagerDashboardState {
  final String message;

  ManagerDashboardError(this.message);
}

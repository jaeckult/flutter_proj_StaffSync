import 'package:equatable/equatable.dart';

abstract class ManagerDashboardEvent extends Equatable {
  const ManagerDashboardEvent();
  @override
  List<Object?> get props => [];
}

class ManagerDashboardFetchRequested extends ManagerDashboardEvent {
  const ManagerDashboardFetchRequested();
}

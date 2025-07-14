import 'package:equatable/equatable.dart';

abstract class LeaveDashboardEvent extends Equatable {
  const LeaveDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LeaveDashboardFetchRequested extends LeaveDashboardEvent {
  const LeaveDashboardFetchRequested();
}

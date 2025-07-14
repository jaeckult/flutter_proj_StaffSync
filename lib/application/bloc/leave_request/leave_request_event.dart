import 'package:equatable/equatable.dart';

abstract class LeaveRequestEvent extends Equatable {
  const LeaveRequestEvent();
  @override
  List<Object?> get props => [];
}

class LeaveRequestFetchRequested extends LeaveRequestEvent {
  const LeaveRequestFetchRequested();
}

class LeaveRequestAddRequested extends LeaveRequestEvent {
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  const LeaveRequestAddRequested({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });
  @override
  List<Object?> get props => [type, startDate, endDate, reason];
}

class LeaveRequestUpdateRequested extends LeaveRequestEvent {
  final int id;
  final String status;
  const LeaveRequestUpdateRequested(this.id, this.status);
  @override
  List<Object?> get props => [id, status];
}

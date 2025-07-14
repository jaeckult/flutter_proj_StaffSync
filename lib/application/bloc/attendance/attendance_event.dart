import 'package:equatable/equatable.dart';
import 'package:staffsync/domain/model/attendance.model.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

class AttendanceFetchRequested extends AttendanceEvent {
  final bool showLoading;
  const AttendanceFetchRequested({this.showLoading = true});
  @override
  List<Object?> get props => [showLoading];
}

class AttendanceCheckInRequested extends AttendanceEvent {
  final AttendanceResponse attendanceResponse;
  const AttendanceCheckInRequested(this.attendanceResponse);
  @override
  List<Object?> get props => [attendanceResponse];
}

class AttendanceCheckOutRequested extends AttendanceEvent {
  const AttendanceCheckOutRequested();
}

class AttendanceDeleteRequested extends AttendanceEvent {
  final int id;
  const AttendanceDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

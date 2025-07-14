import 'package:equatable/equatable.dart';
import 'package:staffsync/domain/model/attendance.model.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceData extends AttendanceState {
  final List<Attendance> attendance;
  final bool isCheckingIn;
  final bool isCheckingOut;

  const AttendanceData(this.attendance, {this.isCheckingIn = false, this.isCheckingOut = false});

  AttendanceData copyWith({List<Attendance>? attendance, bool? isCheckingIn, bool? isCheckingOut}) {
    return AttendanceData(
      attendance ?? this.attendance,
      isCheckingIn: isCheckingIn ?? this.isCheckingIn,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
    );
  }

  @override
  List<Object?> get props => [attendance, isCheckingIn, isCheckingOut];
}

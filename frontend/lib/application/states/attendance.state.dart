import 'package:staffsync/domain/model/attendance.model.dart';

sealed class AttendanceState {
  const AttendanceState();
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

class AttendanceData extends AttendanceState {
  final List<Attendance> attendance;
  const AttendanceData(this.attendance);
}

class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);
}

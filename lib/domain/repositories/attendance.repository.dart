import 'package:staffsync/domain/model/attendance.model.dart';

abstract class AttendanceRepository {
  Future<List<Attendance>> getAttendances(String token);
  Future<void> checkIn(AttendanceResponse attendanceResponse);
  Future<void> checkOut(AttendanceResponse attendanceResponse);
}

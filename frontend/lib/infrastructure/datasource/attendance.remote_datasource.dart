import 'package:staffsync/domain/model/attendance.model.dart';

abstract class IAttendanceRemoteDatasourceImpl {
  Future<List<Attendance>> fetchAttendances(String token, String endpoint);
  Future<void> checkInAttendance(AttendanceResponse attendanceResponse, String token, String endpoint);
  Future<void> checkOutAttendance(AttendanceResponse attendanceResponse, String token, String endpoint);

}

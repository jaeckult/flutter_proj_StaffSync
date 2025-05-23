import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/states/attendance.state.dart' as states;
import 'package:staffsync/application/states/leaveRequest.state.dart';
import 'package:staffsync/domain/model/attendance.model.dart';
import 'package:staffsync/domain/model/leaveRequest.model.dart';
import 'package:staffsync/domain/repositories/attendance.repository.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/leaveRequest.repository.dart';

class AttendanceNotifier extends StateNotifier<states.AttendanceState> {
  final AuthRepository authRepository;
  final AttendanceRepository attendanceRepository;

  AttendanceNotifier(this.authRepository, this.attendanceRepository)
    : super(const states.AttendanceLoading());

  Future<void> getAttendances() async {
    try {
      state = const states.AttendanceLoading();
      final token = await authRepository.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token is missing");
      }

      final requests = await attendanceRepository.getAttendances(token);
      state = states.AttendanceData(requests);
    } catch (error) {
      print("Attendance error: $error");
      state = states.AttendanceError(error.toString());
    }
  }

  Future<void> checkIn(AttendanceResponse attendanceResponse) async {
    try {
      state = const states.AttendanceLoading();
      await attendanceRepository.checkIn(attendanceResponse);
      await getAttendances(); // Refresh the attendance list
    } catch (error) {
      print("Check-in error: $error");
      state = states.AttendanceError(error.toString());
      rethrow;
    }
  }

  Future<void> checkOut() async {
    try {
      state = const states.AttendanceLoading();
      final attendanceResponse = AttendanceResponse(
        message: 'Checking out...',
        attendance: AttendanceData(
          id: 0, // This will be set by the backend
          checkIn: DateTime.now(),
          attendance: 'PRESENT',
        ),
      );
      await attendanceRepository.checkOut(attendanceResponse);
      await getAttendances(); // Refresh the attendance list
    } catch (error) {
      print("Check-out error: $error");
      state = states.AttendanceError(error.toString());
      rethrow;
    }
  }

  bool hasActiveCheckIn() {
    if (state is states.AttendanceData) {
      final today = DateTime.now();
      final todayAttendance = (state as states.AttendanceData).attendance
          .where((a) => a.date.year == today.year && 
                        a.date.month == today.month && 
                        a.date.day == today.day)
          .where((a) => a.checkOut == null)
          .firstOrNull;
      
      return todayAttendance != null;
    }
    return false;
  }

  List<Attendance> getTodayAttendance() {
    if (state is states.AttendanceData) {
      final today = DateTime.now();
      return (state as states.AttendanceData).attendance
          .where((a) => a.date.year == today.year && 
                        a.date.month == today.month && 
                        a.date.day == today.day)
          .toList();
    }
    return [];
  }
}
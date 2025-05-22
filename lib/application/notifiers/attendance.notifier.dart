import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/domain/repositories/attendance.repository.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';

class AttendanceNotifier extends StateNotifier<void> {
    final AuthRepository authRepository;
    final AttendanceRepository attendanceRepository;
    AttendanceNotifier(this.authRepository, this.attendanceRepository) : super(null);
    Future<void> checkIn() async {
    try {
      final token = await authRepository.getToken(); // assume async

      if (token == null || token.isEmpty) {
        throw Exception("Token is missing");
      }

      await attendanceRepository.checkIn(token);

      print("✅ User checked in successfully");
    } catch (error) {
      print("❌ Check-in error: $error");
      if (error is Exception) {
        rethrow;
      } else {
        throw Exception("Unknown error when trying to check in");
      }
    }
  }


}
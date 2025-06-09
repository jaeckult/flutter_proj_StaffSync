import 'package:dio/dio.dart';
import 'package:staffsync/domain/model/attendance.model.dart';
import 'package:staffsync/infrastructure/datasource/attendance.remote_datasource.dart';

class AttendanceRemoteDatasourceImpl implements IAttendanceRemoteDatasourceImpl {
  final Dio dio;

  AttendanceRemoteDatasourceImpl(this.dio);

  @override
  Future<List<Attendance>> fetchAttendances(String token, String endpoint) async {
    try {
      final response = await dio.get(
        'http://$endpoint:3000/api/attendance', 
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Attendance.fromJson(json)).toList();
    } on DioException catch (e) {
      final error = e.response?.data['error'] ?? 'Error fetching attendance records';
      throw Exception(error);
    }
  }

  @override
  Future<void> checkInAttendance(
    AttendanceResponse attendanceResponse,
    String token,
    String endpoint,
  ) async {
    try {
      await dio.post(
        'http://$endpoint:3000/api/attendance/check-in', // or use endpoint if dynamic
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      final error = e.response?.data['error'] ?? 'Error checking in';
      throw Exception(error);
    }
  }

  @override
  Future<void> checkOutAttendance(
    AttendanceResponse attendanceResponse,
    String token,
    String endpoint,
  ) async {
    try {
      await dio.post(
        'http://$endpoint:3000/api/attendance/check-out', // or use endpoint if dynamic
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      final error = e.response?.data['error'] ?? 'Error checking out';
      throw Exception(error);
    }
  }
  @override
  Future<void> clearAttendance(
    AttendanceResponse attendanceResponse,
    String token,
    String endpoint,
  ) async {
    try {
      await dio.delete(
        'http://$endpoint:3000/api/attendance/clear', 
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      final error = e.response?.data['error'] ?? 'Error clearing attendance';
      throw Exception(error);
    }
  }

  @override
  Future<void> deleteAttendance(int id, String token, String endpoint) async {
    try {
      await dio.delete(
        'http://$endpoint:3000/api/attendance/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      final error = e.response?.data['error'] ?? 'Error deleting attendance record';
      throw Exception(error);
    }
  }
}

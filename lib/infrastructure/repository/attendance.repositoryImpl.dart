import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/domain/model/attendance.model.dart';
import 'package:staffsync/domain/repositories/attendance.repository.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/infrastructure/datasource/attendance.remote_datasource.dart';
import 'package:staffsync/infrastructure/datasource/remote_data_source.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final IAttendanceRemoteDatasourceImpl remoteDataSource;
  final SecureStorage secureStorage;

Future<String> _getEndpoint() async =>
      await secureStorage.read("endpoint") ?? "";

  AttendanceRepositoryImpl(this.remoteDataSource, this.secureStorage);
  
  @override
  Future<void> checkIn(AttendanceResponse attendanceResponse) async {
    final endpoint = await _getEndpoint();
    final token = await secureStorage.read("token") ?? "";
    if (token.isEmpty) {
      throw Exception("Token is missing");
    }
    await remoteDataSource.checkInAttendance(attendanceResponse, token, endpoint);
  }

  Future<void> checkOut(AttendanceResponse attendanceResponse) async {
    final endpoint = await _getEndpoint();
    final token = await secureStorage.read("token") ?? "";
    if (token.isEmpty) {
      throw Exception("Token is missing");
    }
    await remoteDataSource.checkOutAttendance(attendanceResponse, token, endpoint);
  }

  @override
  Future<List<Attendance>> getAttendances(String token) async {
    final endpoint = await _getEndpoint();
    return await remoteDataSource.fetchAttendances(token, endpoint);
  }
  
}
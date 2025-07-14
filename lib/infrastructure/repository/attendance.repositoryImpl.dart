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

  // In-memory cache for attendances
  List<Attendance>? _cache;
  DateTime? _cacheTime;
  final Duration _ttl = const Duration(seconds: 200);

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
    // Invalidate cache after mutation
    _cache = null;
    _cacheTime = null;
  }

  @override
  Future<void> checkOut(AttendanceResponse attendanceResponse) async {
    final endpoint = await _getEndpoint();
    final token = await secureStorage.read("token") ?? "";
    if (token.isEmpty) {
      throw Exception("Token is missing");
    }
    await remoteDataSource.checkOutAttendance(attendanceResponse, token, endpoint);
    // Invalidate cache after mutation
    _cache = null;
    _cacheTime = null;
  }

  @override
  Future<List<Attendance>> getAttendances() async {
    // Serve from cache if fresh
    if (_cache != null && _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _ttl) {
      return _cache!;
    }
    final endpoint = await _getEndpoint();
    final token = await secureStorage.read("token") ?? "";
    if (token.isEmpty) {
      throw Exception("Token is missing");
    }
    final data = await remoteDataSource.fetchAttendances(token, endpoint);
    // Update cache
    _cache = List<Attendance>.from(data);
    _cacheTime = DateTime.now();
    return _cache!;
  }

  @override
  Future<void> deleteAttendance(int id) async {
    final endpoint = await _getEndpoint();
    final token = await secureStorage.read("token") ?? "";
    if (token.isEmpty) {
      throw Exception("Token is missing");
    }
    await remoteDataSource.deleteAttendance(id, token, endpoint);
    // Invalidate cache after mutation
    _cache = null;
    _cacheTime = null;
  }
}
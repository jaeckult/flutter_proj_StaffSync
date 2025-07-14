import 'package:staffsync/domain/model/leaveRequest.model.dart';
import 'package:staffsync/domain/repositories/leaveRequest.repository.dart';
import 'package:staffsync/infrastructure/datasource/leaveRequest.remote_datasourceImpl.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class LeaveRequestRepositoryImpl implements LeaveRequestRepository {
  final ILeaveRequestRemoteDatasource remoteDataSource;
  final SecureStorage secureStorage;

  // In-memory cache
  List<LeaveRequest>? _cache;
  DateTime? _cacheTime;
  final Duration _ttl = const Duration(seconds: 30);

  LeaveRequestRepositoryImpl(this.remoteDataSource, this.secureStorage);

  Future<String> _getEndpoint() async =>
      await secureStorage.read("endpoint") ?? "";

  @override
  Future<List<LeaveRequest>> getLeaveRequests(String token) async {
    // Serve from cache if fresh
    if (_cache != null && _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _ttl) {
      return _cache!;
    }
    final endpoint = await _getEndpoint();
    final data = await remoteDataSource.fetchLeaveRequests(token, endpoint);
    _cache = List<LeaveRequest>.from(data);
    _cacheTime = DateTime.now();
    return _cache!;
  }

  @override
  Future<void> addLeaveRequests(LeaveRequestCreate leaveRequestCreate) async {
    final endpoint = await _getEndpoint();
    final token = await secureStorage.read("token") ?? "";
    if (token.isEmpty) {
      throw Exception("Token is missing");
    }
    await remoteDataSource.createLeaveRequests(leaveRequestCreate, token, endpoint);
    // Invalidate cache
    _cache = null;
    _cacheTime = null;
  }

  @override
  Future<void> updateLeaveRequest(int id, String status, String token) async {
    final endpoint = await _getEndpoint();
    await remoteDataSource.updateLeaveRequest(id, status, token, endpoint);
    // Invalidate cache
    _cache = null;
    _cacheTime = null;
  }
}

import 'package:staffsync/domain/model/leaveDashboard.model.dart';
import 'package:staffsync/domain/repositories/leaveDashboard.repository.dart';
import 'package:staffsync/infrastructure/datasource/leaveDashboard.remote_datasource.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class LeaveDashboardRepositoryImpl implements LeaveDashboardRepository {
  final ILeaveDashboardRemoteDatasource remoteDataSource;
  final SecureStorage secureStorage;

  // In-memory cache
  List<LeaveDashboard>? _cache;
  DateTime? _cacheTime;
  final Duration _ttl = const Duration(seconds: 30);

  LeaveDashboardRepositoryImpl(this.remoteDataSource, this.secureStorage);

  Future<String> _getEndpoint() async =>
      await secureStorage.read("endpoint") ?? "";

  @override
  Future<List<LeaveDashboard>> getLeaveDashboardStats(String token) async {
    // Serve from cache if fresh
    if (_cache != null && _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _ttl) {
      return _cache!;
    }
    final endpoint = await _getEndpoint();
    final data = await remoteDataSource.fetchLeaveDashboardStats(token, endpoint);
    _cache = List<LeaveDashboard>.from(data);
    _cacheTime = DateTime.now();
    return _cache!;
  }
}

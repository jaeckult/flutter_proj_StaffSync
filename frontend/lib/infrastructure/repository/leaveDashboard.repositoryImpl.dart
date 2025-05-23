import 'package:staffsync/domain/model/leaveDashboard.model.dart';
import 'package:staffsync/domain/repositories/leaveDashboard.repository.dart';
import 'package:staffsync/infrastructure/datasource/leaveDashboard.remote_datasource.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class LeaveDashboardRepositoryImpl implements LeaveDashboardRepository {
  final ILeaveDashboardRemoteDatasource remoteDataSource;
  final SecureStorage secureStorage;

  LeaveDashboardRepositoryImpl(this.remoteDataSource, this.secureStorage);

  Future<String> _getEndpoint() async =>
      await secureStorage.read("endpoint") ?? "";

  @override
  Future<List<LeaveDashboard>> getLeaveDashboardStats(String token) async {
    final endpoint = await _getEndpoint();
    return await remoteDataSource.fetchLeaveDashboardStats(token, endpoint);
  }
}

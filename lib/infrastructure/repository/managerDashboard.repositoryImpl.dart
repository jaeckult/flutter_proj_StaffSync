import 'package:staffsync/domain/model/managerDashboard.model.dart';
import 'package:staffsync/domain/repositories/managerDashboard.repository.dart';
import 'package:staffsync/infrastructure/datasource/managerDashboard.remote_datasource.dart';
import 'package:staffsync/infrastructure/datasource/managerDashboard.remote_datasourceImpl.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class ManagerDashboardRepositoryImpl implements ManagerdashboardRepository {
  final IManagerDashboardRemoteDatasource remoteDataSource;
  final SecureStorage secureStorage;

  ManagerDashboardRepositoryImpl(this.remoteDataSource, this.secureStorage);

  Future<String> _getEndpoint() async =>
      await secureStorage.read("endpoint") ?? "";

  @override
  Future<List<Managerdashboard>> getManagerDashboardStats(String token) async {
    final endpoint = await _getEndpoint();
    return await remoteDataSource.fetchManagerDashboardStats(token, endpoint);
  }
}

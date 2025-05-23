import 'package:staffsync/domain/model/leaveDashboard.model.dart';
import 'package:staffsync/domain/model/leaveRequest.model.dart';
import 'package:staffsync/domain/repositories/leaveRequest.repository.dart';
import 'package:staffsync/infrastructure/datasource/leaveDashboard.remote_datasource.dart';
import 'package:staffsync/infrastructure/datasource/leaveRequest.remote_datasourceImpl.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class LeaveRequestRepositoryImpl implements LeaveRequestRepository {
  final ILeaveRequestRemoteDatasource remoteDataSource;
  final SecureStorage secureStorage;

  LeaveRequestRepositoryImpl(this.remoteDataSource, this.secureStorage);

  Future<String> _getEndpoint() async =>
      await secureStorage.read("endpoint") ?? "";

  @override
  Future<List<LeaveRequest>> getLeaveRequests(String token) async {
    final endpoint = await _getEndpoint();
    return await remoteDataSource.fetchLeaveRequests(token, endpoint);
  }

  @override
  Future<void> addLeaveRequests(LeaveRequestCreate leaveRequestCreate) async {
    final endpoint = await _getEndpoint();
    final token = await secureStorage.read("token") ?? "";
    if (token.isEmpty) {
      throw Exception("Token is missing");
    }
    await remoteDataSource.createLeaveRequests(leaveRequestCreate, token, endpoint);
  }
}

import 'package:dio/dio.dart';
import 'package:staffsync/domain/model/leaveDashboard.model.dart';
import 'package:staffsync/infrastructure/datasource/leaveDashboard.remote_datasource.dart';

class LeaveDashboardRemoteDatasourceImpl implements ILeaveDashboardRemoteDatasource {
  final Dio dio;

  LeaveDashboardRemoteDatasourceImpl(this.dio);

  @override
  Future<List<LeaveDashboard>> fetchLeaveDashboardStats(
    String token,
    String endpoint,
  ) async {
    try {
      final response = await dio.get(
        'http://localhost:3000/api/leaveRequest/stats', // or use endpoint
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final dashboard = LeaveDashboard.fromJson(data);
      return [dashboard];
    } on DioException catch (e) {
      final error = e.response?.data['error'] ?? 'Error fetching leave dashboard stats';
      throw Exception(error);
    }
  }
}

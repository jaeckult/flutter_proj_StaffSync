import 'package:dio/dio.dart';
import 'package:staffsync/domain/model/managerDashboard.model.dart';
import 'package:staffsync/infrastructure/datasource/managerDashboard.remote_datasourceImpl.dart';

class ManagerDashboardRemoteDatasourceImpl implements IManagerDashboardRemoteDatasource {
  final Dio dio;

  ManagerDashboardRemoteDatasourceImpl(this.dio);

  @override
  Future<List<Managerdashboard>> fetchManagerDashboardStats(
    String token,
    String endpoint,
  ) async {
    try {
      final today = DateTime.now();
      final response = await dio.get(
        'http://localhost:3000/api/attendance/stats',
        queryParameters: {
          'startDate': today.toIso8601String().split('T')[0],
          'endDate': today.toIso8601String().split('T')[0],
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final dashboard = Managerdashboard.fromJson(data);
      return [dashboard];
    } on DioException catch (e) {
      final error = e.response?.data['error'] ?? 'Error fetching leave dashboard stats';
      throw Exception(error);
    }
  }
}

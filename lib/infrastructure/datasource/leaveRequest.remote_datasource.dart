import 'package:dio/dio.dart';
import 'package:staffsync/domain/model/leaveRequest.model.dart';
import 'package:staffsync/infrastructure/datasource/leaveRequest.remote_datasourceImpl.dart';

class LeaveRequestRemoteDatasourceImpl implements ILeaveRequestRemoteDatasource {
  final Dio dio;

  LeaveRequestRemoteDatasourceImpl(this.dio);

  @override
  Future<List<LeaveRequest>> fetchLeaveRequests(String token, String endpoint) async {
    try {
      final response = await dio.get(
        endpoint, // e.g. 'http://localhost:3000/api/leaveRequest'
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((json) => LeaveRequest.fromJson(json)).toList();
      } else {
        throw Exception('Error fetching leave requests');
      }
    } on DioError catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching leave requests');
    }
  }

  @override
  Future<void> createLeaveRequests(
      LeaveRequestCreate leaveRequestCreate, String token, String endpoint) async {
    try {
      final response = await dio.post(
        "http://localhost:3000/api/leaveRequest", 
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
        data: leaveRequestCreate.toJson(),
      );

      if (response.statusCode != 201) {
        throw Exception('Error creating leave request');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating leave request');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:staffsync/domain/model/leaveDashboard.model.dart';
import 'package:staffsync/infrastructure/datasource/leaveDashboard.remote_datasource.dart';

class LeaveDashboardRemoteDatasourceimpl
    implements ILeaveDashboardRemoteDatasource {
  final http.Client httpClient;

  LeaveDashboardRemoteDatasourceimpl(this.httpClient);

  @override
  Future<List<LeaveDashboard>> fetchLeaveDashboardStats(
    String token,
    String endpoint,
  ) async {
    final headers = {"Authorization": "Bearer $token"};
    final response = await httpClient.get(
      Uri.parse('http://localhost:3000/api/leaveRequest/stats'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Create a single LeaveDashboard object from the response
      final dashboard = LeaveDashboard.fromJson(data);
      // Return it as a list with a single item
      return [dashboard];
    } else {
      throw Exception('Error fetching leave dashboard stats');
    }
  }
}

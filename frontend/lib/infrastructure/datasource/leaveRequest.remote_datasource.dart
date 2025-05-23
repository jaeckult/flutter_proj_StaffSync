import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:staffsync/domain/model/leaveRequest.model.dart';
import 'package:staffsync/infrastructure/datasource/leaveRequest.remote_datasourceImpl.dart';

class LeaveRequestRemoteDatasourceImpl
    implements ILeaveRequestRemoteDatasource {
  final http.Client httpClient;

  LeaveRequestRemoteDatasourceImpl(this.httpClient);

  @override
  Future<List<LeaveRequest>> fetchLeaveRequests(
    String token,
    String endpoint,
  ) async {
    final headers = {"Authorization": "Bearer $token"};
    final response = await httpClient.get(
      Uri.parse('http://localhost:3000/api/leaveRequest'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => LeaveRequest.fromJson(json)).toList();
    } else {
      throw Exception('Error fetching leave requests');
    }
  }

  @override
  Future<void> createLeaveRequests(
    LeaveRequestCreate leaveRequestCreate,
    String token,
    String endpoint,
  ) async {
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    final response = await httpClient.post(
      Uri.parse('http://localhost:3000/api/leaveRequest'),
      headers: headers,
      body: json.encode(leaveRequestCreate.toJson()),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error["message"] ?? 'Error creating leave request');
    }
  }
}

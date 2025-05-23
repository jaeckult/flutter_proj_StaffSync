import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:staffsync/domain/model/attendance.model.dart';
import 'package:staffsync/infrastructure/datasource/attendance.remote_datasource.dart';
import 'package:staffsync/infrastructure/datasource/attendance.remote_datasourceImpl.dart';

class AttendanceRemoteDatasourceImpl
    implements IAttendanceRemoteDatasourceImpl {
  final http.Client httpClient;

  AttendanceRemoteDatasourceImpl(this.httpClient);

  @override
  Future<List<Attendance>> fetchAttendances(
    String token,
    String endpoint,
  ) async {
    final headers = {"Authorization": "Bearer $token"};
    final response = await httpClient.get(
      Uri.parse('http://localhost:3000/api/attendance'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => Attendance.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error fetching attendance records');
    }
  }

  @override
  Future<void> checkInAttendance(
    AttendanceResponse attendanceResponse,
    String token,
    String endpoint,
  ) async {
    final headers = {"Authorization": "Bearer $token"};
    final response = await httpClient.post(
      Uri.parse('http://localhost:3000/api/attendance/check-in'),
      headers: headers,
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error checking in');
    }
  }

  @override
  Future<void> checkOutAttendance(
    AttendanceResponse attendanceResponse,
    String token,
    String endpoint,
  ) async {
    final headers = {"Authorization": "Bearer $token"};
    final response = await httpClient.post(
      Uri.parse('http://localhost:3000/api/attendance/check-out'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error checking out');
    }
  }
}

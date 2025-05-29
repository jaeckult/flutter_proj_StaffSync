import 'package:dio/dio.dart';
import 'package:staffsync/domain/model/holiday.model.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class RemoteDataSource {
  final Dio dio;
  RemoteDataSource(this.dio);

  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorage.instance.read("token");
    return {"Authorization": "Bearer $token"};
  }

  Future<Map<String, dynamic>> logIn(
    String username,
    String password,
  ) async {
    try {
      final response = await dio.post(
        'http://localhost:3000/api/login',
        data: {
          "username": username,
          "password": password,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data["role"] == null || data["token"] == null || data["id"] == null) {
        throw Exception('Invalid response from server: missing required fields');
      }

      return data;
    } on DioException catch (e) {
      final error = e.response?.data;
      throw Exception(error["message"] ?? 'Invalid credentials!');
    }
  }

  Future<Map<String, dynamic>> signup(
    String endpoint,
    String username,
    String password,
    String email,
    String fullName,
    String gender,
    String employmentType,
    String designation,
    String dateOfBirth,
    String role,
  ) async {
    try {
      final response = await dio.post(
        'http://localhost:3000/api/signup',
        data: {
          "username": username,
          "password": password,
          "email": email,
          "fullName": fullName,
          "gender": gender,
          "employmentType": employmentType,
          "designation": designation,
          "dateOfBirth": dateOfBirth,
          "role": role,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data["role"] == null) {
        throw Exception('Invalid response from server: missing role field');
      }

      return data;
    } on DioException catch (e) {
      final error = e.response?.data;
      throw Exception(error["message"] ?? 'Signup failed!');
    }
  }

  Future<Map<String, dynamic>> getCurrUser(int id) async {
    try {
      final response = await dio.get(
        'http://localhost:3000/api/users/$id',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final error = e.response?.data;
      throw Exception(error["message"] ?? 'Fetching current user failed!');
    }
  }

  Future<void> checkIn(String token) async {
    try {
      await dio.post(
        'http://localhost:3000/api/attendance/check-in',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
    } on DioException catch (e) {
      final error = e.response?.data;
      throw Exception('Check-in failed: ${error['error']}');
    }
  }

  Future<List<User>> getUsers(String token) async {
    try {
      final response = await dio.get(
        'http://localhost:3000/api/users/employees/',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      final data = response.data as List<dynamic>;
      return data.map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      final error = e.response?.data;
      throw Exception('Failed to retrieve users: ${error['message']}');
    }
  }

  Future<void> logout(String? token) async {
    try {
      final response = await dio.post(
        'http://localhost:3000/api/logout/',
        data: {'token': token},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        print("Successfully logged out.");
      } else {
        print("Logout failed. Status: ${response.statusCode}, Body: ${response.data}");
      }
    } on DioException catch (e) {
      print("Error occurred during logout: ${e.message}");
    }
  }

  Future<List<Holiday>> getHolidayList() async {
    try {
      final response = await dio.get(
        'http://localhost:3000/api/holiday',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      final data = response.data as List<dynamic>;
      return data.map((json) => Holiday.fromJson(json)).toList();
    } on DioException catch (e) {
      final error = e.response?.data;
      throw Exception(error["message"] ?? 'Fetching holidays failed!');
    }
  }
}

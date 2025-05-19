import 'package:dio/dio.dart';

class NetworkService {
  final Dio _dio;
  final String baseUrl = 'http://localhost:3000';

  NetworkService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<String> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['role'] as String;
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> signup(
    String username,
    String password,
    String email,
    String fullname,
    String gender,
    String employmentType,
    String designation,
    String dateOfBirth,
    String role,
  ) async {
    try {
      final response = await _dio.post(
        '/api/signup',
        data: {
          'username': username,
          'password': password,
          'email': email,
          'fullname': fullname,
          'gender': gender,
          'employmentType': employmentType,
          'designation': designation,
          'dateOfBirth': dateOfBirth,
          'role': role,
        },
      );
      
      if (response.statusCode != 201) {
        throw Exception('Signup failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.receiveTimeout:
        return Exception('Receive timeout');
      case DioExceptionType.sendTimeout:
        return Exception('Send timeout');
      case DioExceptionType.badResponse:
        return Exception(error.response?.data['message'] ?? 'Server error');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error');
    }
  }
}

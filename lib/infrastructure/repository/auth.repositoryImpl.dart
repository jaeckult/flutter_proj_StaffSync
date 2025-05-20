import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/infrastructure/datasource/remote_data_source.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.secureStorage);

  @override
  Future<String> logIn(String username, String password) async {
    final endpoint = await secureStorage.read("endpoint");
    if (endpoint == null) {
      throw Exception('Endpoint not configured');
    }
    try {
      final data = await remoteDataSource.logIn(endpoint, username, password);
      print('Repository received data: $data');

      // Store token
      final token = data["access_token"];
      if (token == null) {
        throw Exception('Access token not found in response');
      }
      await secureStorage.write("token", token.toString());

      // Store role
      final role = data["role"];
      if (role == null) {
        throw Exception('Role not found in response');
      }
      await secureStorage.write("role", role.toString());

      // Store userId
      final userId = data["userId"];
      if (userId == null) {
        throw Exception('User ID not found in response');
      }
      await secureStorage.write("id", userId.toString());

      return role.toString();
    } catch (error) {
      print('Login error: $error');
      if (error is Exception) {
        rethrow;
      }
      throw Exception(error.toString().split(":")[1]);
    }
  }

  @override
  Future<String> signup(
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
    final endpoint = await secureStorage.read("endpoint");
    if (endpoint == null) {
      throw Exception('Endpoint not configured');
    }
    try {
      final data = await remoteDataSource.signup(
        endpoint,
        username,
        password,
        email,
        fullname,
        gender,
        employmentType,
        designation,
        dateOfBirth,
        role,
      );
      print('Repository received signup data: $data');

      final responseRole = data["role"];
      if (responseRole == null) {
        throw Exception('Role not returned from server');
      }
      return responseRole.toString();
    } catch (error) {
      print('Signup error: $error');
      if (error is Exception) {
        rethrow;
      }
      throw Exception(error.toString().split(":")[1]);
    }
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read("token");
  }

  @override
  Future<String?> getRole() async {
    return await secureStorage.read("role");
  }

  @override
  Future<void> clearData() async {
    await secureStorage.write("token", null);
    await secureStorage.write("role", null);
    await secureStorage.write("id", null);
  }
}

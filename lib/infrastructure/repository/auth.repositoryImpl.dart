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
    try {
      final data = await remoteDataSource.logIn(endpoint!, username, password);

      await secureStorage.write("token", data["access_token"]);
      await secureStorage.write("role", data["role"]);
      await secureStorage.write("id", data["userId"].toString());
      return data["role"];
    } catch (error) {
      throw Exception(error.toString().split(":")[1]);
    }
  }

  @override
  Future<void> signUpCustomer(
    String email,
    String password,
    String phone,
    String fullName,
  ) async {
    final endpoint = await secureStorage.read("endpoint");
    print("hello in repo impl");
    await remoteDataSource.signUpCustomer(
      endpoint!,
      email,
      password,
      phone,
      fullName,
    );
  }

  @override
  Future<void> signUpTechnician(
    String email,
    String password,
    String phone,
    String fullName,
    String skills,
    String experience,
    String educationLevel,
    String availableLocation,
    String additionalBio,
  ) async {
    final endpoint = await secureStorage.read("endpoint");
    await remoteDataSource.signUpTechnician(
      endpoint!,
      email,
      password,
      phone,
      fullName,
      skills,
      experience,
      educationLevel,
      availableLocation,
      additionalBio,
    );
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

  @override
  Future<void> deleteAccount() async {
    final role = await secureStorage.read("role");
    final id = await secureStorage.read("id");
    final endpoint = await secureStorage.read("endpoint");
    await remoteDataSource.deleteAccount(endpoint!, id!, role!);
    clearData();
  }
}

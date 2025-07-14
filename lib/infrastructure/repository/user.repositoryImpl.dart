import 'package:staffsync/domain/model/notification.model.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/user.repository.dart';
import 'package:staffsync/infrastructure/datasource/remote_data_source.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;

  UserRepositoryImpl(this.remoteDataSource, this.secureStorage);

  @override
  Future<User> getCurrUser(int id, String endpoint) async {
    try {
      final data = await remoteDataSource.getCurrUser(id, endpoint);
      return User.fromJson(data);
    } catch(e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(e.toString());
    }
  }
  
  @override
  Future<List<User>> getEmployees(String token) async {
    try {
      final endpoint = await secureStorage.read("endpoint");
      if (endpoint == null) {
        throw Exception('Endpoint not configured');
      }
      final data = await remoteDataSource.getUsers(token, endpoint);
      return data;
    } catch(e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception("Can't retrieve user information");
      }
    }
  }

  @override
  Future<void> deleteEmployee(int id, String token) async {
    try {
      final endpoint = await secureStorage.read("endpoint");
      if (endpoint == null) {
        throw Exception('Endpoint not configured');
      }
      await remoteDataSource.deleteUser(id, token, endpoint);
    } catch(e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception("Can't delete user");
      }
    }
  }

  @override
  Future<void> editProfile(
    int id, 
    String fullName, 
    String designation, 
    String email, 
    String employmentType, 
    String? profilePicture
  ) async {
    try {
      final endpoint = await secureStorage.read("endpoint");
      if (endpoint == null) {
        throw Exception('Endpoint not configured');
      }
      await remoteDataSource.editProfile(
        id,
        fullName,
        designation,
        email,
        employmentType,
        profilePicture,
        endpoint
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception("Can't edit profile");
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationMessage() async {
    try {
      final token = await secureStorage.read("token");
      final endpoint = await secureStorage.read("endpoint");
      if (endpoint == null) {
        throw Exception('Endpoint not configured');
      }
      
      if (token != null) {
        final data = await remoteDataSource.getNotificationMessage(token, endpoint);
        return data;
      } else {
        throw Exception("Token is null");
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception("Can't retrieve notification messages");
      }
    }
  }

  @override
  Future<void> deleteNotification() async {
    try {
      final token = await secureStorage.read("token");
      final endpoint = await secureStorage.read("endpoint");
      if (endpoint == null) {
        throw Exception('Endpoint not configured');
      }
      
      if (token != null) {
        await remoteDataSource.deleteNotification(token, endpoint);
      } else {
        throw Exception("Token is null");
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception("Can't delete notification messages");
      }
    }
  }

  @override
  Future<void> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
    required String token,
    required String endpoint,
  }) async {
    try {
      await remoteDataSource.changePassword(
        userId: userId,
        oldPassword: oldPassword,
        newPassword: newPassword,
        token: token,
        endpoint: endpoint,
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception("Can't change password");
      }
    }
  }
}
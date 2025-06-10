import 'package:dio/dio.dart';
import 'package:staffsync/domain/model/holiday.model.dart';
import 'package:staffsync/domain/model/notification.model.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
    String endpoint,
  ) async {
    try {
      final response = await dio.post(
        'http://$endpoint:3000/api/login',
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
        'http://$endpoint:3000/api/signup',
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

  Future<Map<String, dynamic>> getCurrUser(int id, String endpoint) async {
    try {
      final response = await dio.get(
        'http://$endpoint:3000/api/users/$id',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final error = e.response?.data;
      throw Exception(error["message"] ?? 'Fetching current user failed!');
    }
  }

  Future<void> checkIn(String token, String endpoint) async {
    try {
      await dio.post(
        'http://$endpoint:3000/api/attendance/check-in',
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

  Future<List<User>> getUsers(String token, String endpoint) async {
    try {
      final response = await dio.get(
        'http://$endpoint:3000/api/users/employees/',
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

  Future<void> logout(String? token, String endpoint) async {
    try {
      final response = await dio.post(
        'http://$endpoint:3000/api/logout/',
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

  Future<void> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
    required String token,
    required String endpoint,
  }) async {
    try {
      final response = await dio.patch(
        'http://$endpoint:3000/api/profile/change-password/$userId',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        final error = response.data['error'] ?? 'Failed to change password';
        throw Exception(error);
      }
    } on DioException catch (e) {
      if (e.response?.data is Map && e.response?.data['error'] != null) {
        throw Exception(e.response?.data['error']);
      }
      throw Exception('Failed to change password. Please check your connection and try again.');
    } catch (e) {
      throw Exception('An unexpected error occurred while changing password.');
    }
  }

  Future<void> deleteUser(int id, String token, String endpoint) async {
    try {
      final response = await dio.delete(
        'http://$endpoint:3000/api/users/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user: ${response.data}');
      }
    } on DioException catch (e) {
      print("Error during user deletion: ${e.message}");
      final errorMessage = e.response?.data is Map && e.response?.data["message"] != null
          ? e.response?.data["message"]
          : "Unknown error";
      throw Exception('User deletion failed: $errorMessage');
    } catch (e) {
      print("Unexpected error: $e");
      throw Exception('Unexpected error occurred while deleting user.');
    }
  }

  Future<List<Holiday>> getHolidays(String token, String endpoint) async {
    try {
      final response = await dio.get(
        'http://$endpoint:3000/api/holiday',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      final data = response.data as List<dynamic>;
      return data.map((json) => Holiday.fromJson(json)).toList();
    } on DioException catch (e) {
      final error = e.response?.data;
      throw Exception(error["message"] ?? 'Fetching holidays failed!');
    }
  }

  Future<void> addHoliday(
    String title,
    String startDate,
    String endDate,
    String description,
    int createdById,
    String endpoint,
  ) async {
    try {
      await dio.post(
        'http://$endpoint:3000/api/holiday',
        data: {
          "title": title,
          "startDate": startDate,
          "endDate": endDate,
          "description": description,
          "createdById": createdById,
        },
      );
    } on DioException catch (e) {
      print('DioError in addHoliday: ${e.response?.data}');
      final error = e.response?.data;
      throw Exception(error["message"] ?? 'Adding holiday failed!');
    }
  }

  Future<void> editProfile(
    int id,
    String fullName,
    String designation,
    String email,
    String employmentType,
    String? profilePicture,
    String endpoint,
  ) async {
    final token = await SecureStorage.instance.read("token");
    try {
      final response = await dio.patch(
        'http://$endpoint:3000/api/profile/${id}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "employmentType": employmentType,
          "email": email,
          "fullName": fullName,
          "designation": designation,
          "profilePicture": profilePicture ?? ''
        },
      );
      print('Profile updated: ${response.data}');
    } on DioException catch (e) {
      print(e);
      final error = e.response?.data;
      throw Exception(error["message"] ?? 'Can not edit profile!');
    }
  }

  Future<void> connectToSocket(String token, String endpoint) async {
    IO.Socket socket = IO.io(
      'http://$endpoint:9955',
      IO.OptionBuilder()
          .setTransports(<String>['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );
    socket.connect();
    socket.on('leaveRequestUpdated', (data) {
      print('Leave Request Notification: $data');
      // You can trigger UI update or show notification
    });
    socket.onConnect((_) {
      print('Socket connected: ${socket.id}');
    });
  }

  Future<List<NotificationModel>> getNotificationMessage(String? token, String endpoint) async {
    try {
      final response = await dio.get(
        'http://$endpoint:3000/api/notification',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      final data = response.data as List<dynamic>;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final error = e.response?.data;
      throw Exception('Failed to retrieve messages: ${error['message']}');
    }
  }

  Future<void> deleteNotification(String token, String endpoint) async {
    try {
      await dio.delete(
        'http://$endpoint:3000/api/notification',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
    } on DioException catch (e) {
      print('Cant delete the notification: ${e.response?.data}');
      final error = e.response?.data;
      throw Exception(error["message"] ?? 'Deletion Failed failed!');
    }
  }
}

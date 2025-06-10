import 'package:staffsync/domain/model/notification.model.dart';
import 'package:staffsync/domain/model/user.model.dart';

abstract class UserRepository {
  // Future<Map<String, dynamic>> getMyAttendance(int id);
  Future<User> getCurrUser(int id, String endpoint);
  Future<List<User>> getEmployees(String token);
  Future<void> deleteEmployee(int id, String token);
  Future<void> deleteNotification();
  Future<void> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
    required String token,
    required String endpoint,
  });

  Future<List<NotificationModel>> getNotificationMessage();
  Future<void> editProfile(int id, 
  String fullName, 
  String designation, 
  String email, String employmentType, String? profilePicture
  );
  


}
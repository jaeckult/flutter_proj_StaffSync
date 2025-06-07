import 'package:staffsync/domain/model/user.model.dart';

abstract class UserRepository {
  // Future<Map<String, dynamic>> getMyAttendance(int id);
  Future<User> getCurrUser(int id);
  Future<List<User>> getEmployees(String token);
  Future<void> deleteEmployee(int id, String token);
  Future<void> editProfile(int id, 
  String fullName, 
  String designation, 
  String email, String employmentType, String? profilePicture
  );
  


}
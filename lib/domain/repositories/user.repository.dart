import 'package:staffsync/domain/model/user.model.dart';

abstract class UserRepository {
  // Future<Map<String, dynamic>> getMyAttendance(int id);
  Future<User> getCurrUser(int id);
  Future<List<User>> getEmployees(String token);



}
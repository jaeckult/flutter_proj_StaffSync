import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/domain/model/notification.model.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/user.repository.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class UserNotifier extends StateNotifier<User?> {
    final AuthRepository authRepository;
    final UserRepository userRepository;
    final SecureStorage secureStorage;
    UserNotifier(this.authRepository, this.userRepository) 
      : secureStorage = SecureStorage.instance,
        super(null);
    Future<void> loadUserFromStorage() async {
      if (state != null) return;
      final id = await authRepository.getId(); 
      final endpoint = await secureStorage.read("endpoint");
      if (id == null) {
        print('No user ID found in storage.');
        state = null;
        return;
      }
      if (endpoint == null) {
        throw Exception('Endpoint not configured');
      }
      final newId = int.parse(id);
      final user = await userRepository.getCurrUser(newId, endpoint);
      state = user;
    }
     Future<void> editProfile
  (int id, 
  String fullName, 
  String designation, 
  String email, String employmentType, String? profilePicture) async{
    try {
      final endpoint = await secureStorage.read("endpoint");
      if (endpoint == null) {
        throw Exception('Endpoint not configured');
      }
      await userRepository.editProfile(id, fullName, designation, email, employmentType, profilePicture);
      state = await userRepository.getCurrUser(id, endpoint);
    }
     catch (e) {
      print('Error in editProfile: $e');
      throw Exception('Cannot edit profile: ${e.toString()}');
    }
  
  }
    Future<List<NotificationModel>> getNotificationMessage() async{
    try {
      return await userRepository.getNotificationMessage();
    }
     catch (e) {
      print('Error getting notifications: $e');
      throw Exception('Cannot retrieve notifications: ${e.toString()}');
    }
  

  }
  Future<void> deleteNotification() async {
    try {
      await userRepository.deleteNotification();
    }catch(e) {
      print('Error deleting notification: $e');
      throw Exception('Cannot delete notification: ${e.toString()}');
    }
  }
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try{
      await userRepository.changePassword(oldPassword, newPassword);
    }
    catch(e) {
      print('Error changing password: $e');
      throw Exception('Cannot change password: ${e.toString()}');
    }
  }

}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/domain/model/notification.model.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/user.repository.dart';

class UserNotifier extends StateNotifier<User?> {
    final AuthRepository authRepository;
    final UserRepository userRepository;
    UserNotifier(this.authRepository, this.userRepository) : super(null);
    Future<void> loadUserFromStorage() async {
      if (state != null) return;
      final id = await authRepository.getId(); 
      if (id == null) {
        print('No user ID found in storage.');
        state = null;
        return;
      }
      final newId = int.parse(id);
      final user = await userRepository.getCurrUser(newId);
      state = user;
    }
     Future<void> editProfile
  (int id, 
  String fullName, 
  String designation, 
  String email, String employmentType, String? profilePicture) async{
    try {
      userRepository.editProfile(id, fullName, designation, email, employmentType, profilePicture);
      state = await userRepository.getCurrUser(id); //let us reload
    }
     catch (e) {
      print('DioError in addHoliday');
      throw Exception('Can not edit profile!');
    }
  
  }
    Future<List<NotificationModel>> getNotificationMessage() async{
    try {
      List<NotificationModel> list = await userRepository.getNotificationMessage();
      return list;
    }
     catch (e) {
      print('DioError in addHoliday');
      throw Exception('Can not edit profile!');
    }
  

  }
  Future<void> deleteNotification() async {
    try {
      await userRepository.deleteNotification();
    }catch(e) {
      print('DioError in delete notification');
      throw Exception('Can not delete notification!');
    }
  }

}
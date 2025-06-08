
import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/domain/model/notification.model.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/user.repository.dart';
import 'package:staffsync/infrastructure/datasource/remote_data_source.dart';
class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource remoteDataSource;
  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> getCurrUser(int id) async {
    try {
     
      final data = await remoteDataSource.getCurrUser(id);
      return User.fromJson(data);

    }
    catch(e) {
      
      if (e is Exception){
        rethrow;
      }
      throw Exception(e.toString());
    }


    
   
  }
  
  @override
  Future<List<User>> getEmployees(String token) async {
    try {
      
      final data = await remoteDataSource.getUsers(token);
      return data;
    }
    catch(e) {
      if (e is Exception) {
       
        rethrow;

      }
      else {
        
        throw Exception("Can't retrive user infromation");
      }
    }
    
  }
  @override
  Future<void> deleteEmployee(int id, String token) async {
    try {
      await remoteDataSource.deleteUser(id, token);
    }
    catch(e) {
      if (e is Exception) {
        rethrow;
      }
      else {
        throw Exception("Can't delete user");
      }
    }
  }

  
    @override
    Future<void> editProfile(int id, 
    String fullName, 
    String designation, 
    String email, String employmentType, String? profilePicture) async {
      final data = await remoteDataSource.editProfile(id,
        fullName, designation, email, employmentType, profilePicture
      );
    
    }@override
Future<List<NotificationModel>> getNotificationMessage() async {
  try {
    final token = await authRepository.getToken();
    
    if (token != null) {
      final data = await remoteDataSource.getNotificationMessage(token);
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
    final token = await authRepository.getToken();
    
    if (token != null) {
      await remoteDataSource.deleteNotification(token);

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
  Future<void> changePassword(String oldPassword, String newPassword) async{
    try {
    final token = await authRepository.getToken();
    final userId = await authRepository.getId();
   
    
    
    if (token != null && userId != null) {
      final castedId = int.parse(userId);
      await remoteDataSource.changePassword(userId: castedId, oldPassword: oldPassword, newPassword: newPassword, token: token);

    } else {
      throw Exception("Token or id is null");
    }

  } catch (e) {
    if (e is Exception) {
      rethrow;
    } else {
      throw Exception("Can't change password");
    }
  }
  

    
  }

}
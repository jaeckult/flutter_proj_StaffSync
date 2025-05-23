import 'dart:convert';

import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/user.repository.dart';
import 'package:staffsync/infrastructure/datasource/remote_data_source.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';
class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource remoteDataSource;
  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> getCurrUser(int id) async {
    try {
      print("getting curr User data...");
      final data = await remoteDataSource.getCurrUser(id);
      print("${data} we received");
      return User.fromJson(data);



    }
    catch(e) {
      print(e);
      if (e is Exception){
        rethrow;
      }
      throw Exception(e.toString());
    }


    
   
  }
  
  @override
  Future<List<User>> getEmployees(String token) async {
    try {
      print("we are trying to get access to all the users");
      final data = await remoteDataSource.getUsers(token);
      print(data);
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
  

  // @override
  // Future<Map<String, dynamic>> getMyAttendance(int id) {
  //    try {
  //     print("getting curr User data...");
  //     final data = await remoteDataSource.getCurrUser(id);
  //     print("${data} we received");
  //     return data;



  //   }
  //   catch(e) {
  //     print(e);
  //     if (e is Exception){
  //       rethrow;
  //     }
  //     throw Exception(e.toString());
  //   }



  
    
  // }
  
}
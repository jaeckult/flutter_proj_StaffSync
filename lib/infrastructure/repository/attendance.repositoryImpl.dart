import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/domain/repositories/attendance.repository.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/infrastructure/datasource/remote_data_source.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final RemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;

  AttendanceRepositoryImpl(this.remoteDataSource, this.secureStorage);
  @override
  Future<void> checkIn(String token) async{
    try {
      final data = await remoteDataSource.checkIn(token);
     

      

    }
    catch(error) {
      print('Login error: $error');
      if (error is Exception) {
        rethrow;
      }
      throw Exception(error.toString().split(":")[1]);
    }
  
  }

  // @override
  // Future<void> checkOut() async {
  
  // }
  
}
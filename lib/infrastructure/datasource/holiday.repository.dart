import 'package:staffsync/domain/model/holiday.model.dart';
import 'package:staffsync/domain/repositories/holiday.repository.dart';
import 'package:staffsync/infrastructure/datasource/remote_data_source.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class HolidayRepositoryImpl implements HolidayRepository {
  final RemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;

  HolidayRepositoryImpl(this.remoteDataSource, this.secureStorage);
  
  @override
  Future<List<Holiday>> getHolidayList() {
    try {
       final data = remoteDataSource.getHolidayList();
       return data;

    }
    catch(e) {
      if (e is Exception) {
        rethrow;
      }
      else{
        print(e);
         throw Exception("Can't retrive user infromation");
      }
    }
   
  }
  @override
  Future<void> addHoliday(Holiday holiday) async {
    try {
      final userIdString = await secureStorage.read('id');
      final createdById = int.tryParse(userIdString ?? '');

      if (createdById == null) {
        throw Exception('User ID not found or invalid.');
      }

      await remoteDataSource.addHoliday(
        holiday.title,
        holiday.startDate.toIso8601String(),
        holiday.endDate.toIso8601String(),
        holiday.description ?? '',
        createdById,
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        print(e);
        throw Exception("Can't add holiday");
      }
    }
  }

 }
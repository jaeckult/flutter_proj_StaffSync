import 'package:staffsync/domain/model/holiday.model.dart';
import 'package:staffsync/domain/repositories/holiday.repository.dart';
import 'package:staffsync/infrastructure/datasource/remote_data_source.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class HolidayRepositoryImpl implements HolidayRepository {
  final RemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;

  HolidayRepositoryImpl(this.remoteDataSource, this.secureStorage);
  
  @override
  Future<List<Holiday>> getHolidayList() async {
    try {
      final token = await secureStorage.read("token");
      final endpoint = await secureStorage.read("endpoint");
      if (endpoint == null) {
        throw Exception('Endpoint not configured');
      }
      if (token == null) {
        throw Exception('Token not found');
      }
      final data = await remoteDataSource.getHolidays(token, endpoint);
      return data;
    } catch(e) {
      if (e is Exception) {
        rethrow;
      } else {
        print(e);
        throw Exception("Can't retrieve holiday information");
      }
    }
  }

  @override
  Future<void> addHoliday(Holiday holiday) async {
    try {
      final userIdString = await secureStorage.read('id');
      final endpoint = await secureStorage.read("endpoint");
      if (endpoint == null) {
        throw Exception('Endpoint not configured');
      }
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
        endpoint,
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
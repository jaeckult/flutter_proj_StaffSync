import 'package:staffsync/domain/model/holiday.model.dart';
import 'package:staffsync/domain/repositories/holiday.repository.dart';
import 'package:staffsync/infrastructure/datasource/remote_data_source.dart';

class HolidayRepositoryImpl implements HolidayRepository {
  final RemoteDataSource remoteDataSource;
  HolidayRepositoryImpl(this.remoteDataSource);
  
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

 }
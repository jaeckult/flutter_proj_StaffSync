import 'package:staffsync/domain/model/holiday.model.dart';

abstract class HolidayRepository {
  Future<List<Holiday>> getHolidayList();
  Future<void> addHoliday(Holiday holiday);
  // Future<void> getHolidayList(AttendanceResponse attendanceResponse);
  // Future<void> checkOut(AttendanceResponse attendanceResponse);
}

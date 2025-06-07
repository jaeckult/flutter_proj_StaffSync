import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/domain/model/holiday.model.dart';
import 'package:staffsync/domain/repositories/holiday.repository.dart';

class HolidayNotifier extends StateNotifier<List<Holiday>>{
  final HolidayRepository holidayRepository;
  HolidayNotifier({required this.holidayRepository}):super([]);
  Future<List<Holiday>> getHolidayList() async {
    try {
      final holidays = await holidayRepository.getHolidayList();
      state = holidays;
      return holidays;
    } catch (e) {
      print('Error fetching holidays: $e');
      return [];
    }
  }

  Future<void> addHoliday(Holiday holiday) async {
    try {
      await holidayRepository.addHoliday(holiday);
      // Refresh the holiday list after adding
      await getHolidayList();
    } catch (e) {
      print('Error adding holiday: $e');
      rethrow;
    }
  }
}
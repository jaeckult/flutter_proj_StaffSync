import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:staffsync/domain/model/attendance.model.dart';
import 'package:staffsync/domain/model/holiday.model.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/attendance.repository.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/holiday.repository.dart';

import 'package:staffsync/infrastructure/datasource/holiday.repository.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';
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



}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffsync/application/bloc/holiday/holiday_event.dart';
import 'package:staffsync/application/bloc/holiday/holiday_state.dart';
import 'package:staffsync/domain/repositories/holiday.repository.dart';

class HolidayBloc extends Bloc<HolidayEvent, HolidayState> {
  final HolidayRepository holidayRepository;

  HolidayBloc({required this.holidayRepository}) : super(const HolidayInitial()) {
    on<HolidayFetchRequested>(_onFetch);
    on<HolidayAddRequested>(_onAdd);
  }

  Future<void> _onFetch(HolidayFetchRequested event, Emitter<HolidayState> emit) async {
    emit(const HolidayLoading());
    try {
      final holidays = await holidayRepository.getHolidayList();
      emit(HolidayLoaded(holidays));
    } catch (e) {
      emit(HolidayError(e.toString()));
    }
  }

  Future<void> _onAdd(HolidayAddRequested event, Emitter<HolidayState> emit) async {
    try {
      await holidayRepository.addHoliday(event.holiday);
      add(const HolidayFetchRequested());
    } catch (e) {
      emit(HolidayError(e.toString()));
    }
  }
}

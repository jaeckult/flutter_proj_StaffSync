import 'package:equatable/equatable.dart';
import 'package:staffsync/domain/model/holiday.model.dart';

abstract class HolidayEvent extends Equatable {
  const HolidayEvent();

  @override
  List<Object?> get props => [];
}

class HolidayFetchRequested extends HolidayEvent {
  const HolidayFetchRequested();
}

class HolidayAddRequested extends HolidayEvent {
  final Holiday holiday;
  const HolidayAddRequested(this.holiday);

  @override
  List<Object?> get props => [holiday];
}

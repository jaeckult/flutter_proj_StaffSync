import 'package:equatable/equatable.dart';
import 'package:staffsync/domain/model/holiday.model.dart';

abstract class HolidayState extends Equatable {
  const HolidayState();

  @override
  List<Object?> get props => [];
}

class HolidayInitial extends HolidayState {
  const HolidayInitial();
}

class HolidayLoading extends HolidayState {
  const HolidayLoading();
}

class HolidayLoaded extends HolidayState {
  final List<Holiday> holidays;
  const HolidayLoaded(this.holidays);

  @override
  List<Object?> get props => [holidays];
}

class HolidayError extends HolidayState {
  final String message;
  const HolidayError(this.message);

  @override
  List<Object?> get props => [message];
}

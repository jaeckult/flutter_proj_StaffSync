import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffsync/application/bloc/attendance/attendance_event.dart';
import 'package:staffsync/application/bloc/attendance/attendance_state.dart' as states;
import 'package:staffsync/domain/model/attendance.model.dart';
import 'package:staffsync/domain/repositories/attendance.repository.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/utils/timezone_helper.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, states.AttendanceState> {
  final AuthRepository authRepository;
  final AttendanceRepository attendanceRepository;

  AttendanceBloc({required this.authRepository, required this.attendanceRepository})
      : super(const states.AttendanceLoading()) {
    on<AttendanceFetchRequested>(_onFetch);
    on<AttendanceCheckInRequested>(_onCheckIn);
    on<AttendanceCheckOutRequested>(_onCheckOut);
    on<AttendanceDeleteRequested>(_onDelete);
  }

  Future<void> _onFetch(AttendanceFetchRequested event, Emitter<states.AttendanceState> emit) async {
    try {
      if (event.showLoading && state is! states.AttendanceData) {
        emit(const states.AttendanceLoading());
      }
      final token = await authRepository.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Token is missing");
      }
      final requests = await attendanceRepository.getAttendances();
      emit(states.AttendanceData(requests));
    } catch (error) {
      emit(states.AttendanceError(error.toString()));
    }
  }

  Future<void> _onCheckIn(AttendanceCheckInRequested event, Emitter<states.AttendanceState> emit) async {
    try {
      if (state is states.AttendanceData) {
        final current = state as states.AttendanceData;
        emit(states.AttendanceData(current.attendance, isCheckingIn: true));
      }
      await attendanceRepository.checkIn(event.attendanceResponse);
      add(const AttendanceFetchRequested(showLoading: false));
    } catch (error) {
      if (state is states.AttendanceData) {
        final current = state as states.AttendanceData;
        emit(states.AttendanceData(current.attendance, isCheckingIn: false));
      } else {
        emit(states.AttendanceError(error.toString()));
      }
    }
  }

  Future<void> _onCheckOut(AttendanceCheckOutRequested event, Emitter<states.AttendanceState> emit) async {
    try {
      if (state is states.AttendanceData) {
        final current = state as states.AttendanceData;
        emit(states.AttendanceData(current.attendance, isCheckingIn: true));
      }
      final attendanceResponse = AttendanceResponse(
        message: 'Checking out...',
        attendance: AttendanceData(
          id: 0,
          checkIn: TimezoneHelper.now(),
          attendance: 'PRESENT',
        ),
      );
      await attendanceRepository.checkOut(attendanceResponse);
      add(const AttendanceFetchRequested(showLoading: false));
    } catch (error) {
      if (state is states.AttendanceData) {
        final current = state as states.AttendanceData;
        emit(states.AttendanceData(current.attendance, isCheckingIn: false));
      } else {
        emit(states.AttendanceError(error.toString()));
      }
    }
  }

  Future<void> _onDelete(AttendanceDeleteRequested event, Emitter<states.AttendanceState> emit) async {
    try {
      emit(const states.AttendanceLoading());
      await attendanceRepository.deleteAttendance(event.id);
      add(const AttendanceFetchRequested(showLoading: false));
    } catch (error) {
      emit(states.AttendanceError(error.toString()));
    }
  }
}

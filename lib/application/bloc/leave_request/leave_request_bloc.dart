import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffsync/application/bloc/leave_request/leave_request_event.dart';
import 'package:staffsync/application/bloc/leave_request/leave_request_state.dart';
import 'package:staffsync/domain/model/leaveRequest.model.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/leaveRequest.repository.dart';

class LeaveRequestBloc extends Bloc<LeaveRequestEvent, LeaveRequestState> {
  final AuthRepository authRepository;
  final LeaveRequestRepository leaveRequestRepository;

  LeaveRequestBloc({required this.authRepository, required this.leaveRequestRepository})
      : super(const LeaveRequestLoading()) {
    on<LeaveRequestFetchRequested>(_onFetch);
    on<LeaveRequestAddRequested>(_onAdd);
    on<LeaveRequestUpdateRequested>(_onUpdate);
  }

  Future<void> _onFetch(LeaveRequestFetchRequested event, Emitter<LeaveRequestState> emit) async {
    try {
      emit(const LeaveRequestLoading());
      final token = await authRepository.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Token is missing");
      }
      final requests = await leaveRequestRepository.getLeaveRequests(token);
      emit(LeaveRequestData(requests));
    } catch (error) {
      emit(LeaveRequestError(error.toString()));
    }
  }

  Future<void> _onAdd(LeaveRequestAddRequested event, Emitter<LeaveRequestState> emit) async {
    try {
      emit(const LeaveRequestLoading());
      final token = await authRepository.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Token is missing");
      }
      final leaveRequest = LeaveRequestCreate(
        type: event.type,
        startDate: event.startDate,
        endDate: event.endDate,
        reason: event.reason,
      );
      await leaveRequestRepository.addLeaveRequests(leaveRequest);
      add(const LeaveRequestFetchRequested());
    } catch (error) {
      emit(LeaveRequestError(error.toString()));
      rethrow;
    }
  }

  Future<void> _onUpdate(LeaveRequestUpdateRequested event, Emitter<LeaveRequestState> emit) async {
    try {
      final token = await authRepository.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Token is missing");
      }
      await leaveRequestRepository.updateLeaveRequest(event.id, event.status, token);
      add(const LeaveRequestFetchRequested());
    } catch (error) {
      // Keep current state; optionally could emit a specific error
    }
  }
}

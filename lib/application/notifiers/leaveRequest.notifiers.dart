import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/states/leaveRequest.state.dart';
import 'package:staffsync/domain/model/leaveRequest.model.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/leaveRequest.repository.dart';

class LeaveRequestNotifier extends StateNotifier<LeaveRequestState> {
  final AuthRepository authRepository;
  final LeaveRequestRepository leaveRequestRepository;

  LeaveRequestNotifier(this.authRepository, this.leaveRequestRepository)
    : super(const LeaveRequestLoading());

  Future<void> getLeaveRequests() async {
    try {
      state = const LeaveRequestLoading();
      final token = await authRepository.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token is missing");
      }

      final requests = await leaveRequestRepository.getLeaveRequests(token);
      state = LeaveRequestData(requests);
    } catch (error) {
      print("Leave request error: $error");
      state = LeaveRequestError(error.toString());
    }
  }

  Future<void> addLeaveRequests({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    try {
      state = const LeaveRequestLoading();
      final token = await authRepository.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token is missing");
      }

      final leaveRequest = LeaveRequestCreate(
        type: type,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );

      await leaveRequestRepository.addLeaveRequests(leaveRequest);
      // Refresh both the requests list and dashboard stats
      await getLeaveRequests();
    } catch (error) {
      print("Leave request error: $error");
      state = LeaveRequestError(error.toString());
      rethrow; // Rethrow to handle in the UI
    }
  }

  Future<void> updateLeaveRequest(int id, String status) async {
    try {
      // Do not change the state to loading here to avoid flickering the entire list
      final token = await authRepository.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token is missing");
      }

      await leaveRequestRepository.updateLeaveRequest(id, status, token);
      // Refresh the requests list to show the updated status
      await getLeaveRequests();
    } catch (error) {
      print("Leave request update error: $error");
      // Consider how to handle errors gracefully, perhaps showing a snackbar
      // or updating the state for just the failed item if possible.
      // For now, we'll just print the error and let getLeaveRequests update.
    }
  }
}

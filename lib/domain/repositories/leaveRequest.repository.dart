import 'package:staffsync/domain/model/leaveRequest.model.dart';

abstract class LeaveRequestRepository {
  Future<List<LeaveRequest>> getLeaveRequests(String token);
  Future<void> addLeaveRequests(LeaveRequestCreate leaveRequestCreate);
}

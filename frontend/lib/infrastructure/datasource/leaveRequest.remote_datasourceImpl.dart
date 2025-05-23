import 'package:staffsync/domain/model/leaveRequest.model.dart';

abstract class ILeaveRequestRemoteDatasource {
  Future<List<LeaveRequest>> fetchLeaveRequests(String token, String endpoint);
  Future<void> createLeaveRequests(LeaveRequestCreate leaveRequestCreate, String token, String endpoint);
}

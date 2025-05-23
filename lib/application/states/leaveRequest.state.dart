import 'package:staffsync/domain/model/leaveDashboard.model.dart';
import 'package:staffsync/domain/model/leaveRequest.model.dart';

sealed class LeaveRequestState {
  const LeaveRequestState();
}

class LeaveRequestLoading extends LeaveRequestState {
  const LeaveRequestLoading();
}

class LeaveRequestData extends LeaveRequestState {
  final List<LeaveRequest> leaveRequest;
  const LeaveRequestData(this.leaveRequest);
}

class LeaveRequestError extends LeaveRequestState {
  final String message;
  const LeaveRequestError(this.message);
}

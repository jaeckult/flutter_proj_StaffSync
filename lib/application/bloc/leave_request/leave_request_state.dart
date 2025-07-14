import 'package:equatable/equatable.dart';
import 'package:staffsync/domain/model/leaveRequest.model.dart';

abstract class LeaveRequestState extends Equatable {
  const LeaveRequestState();

  @override
  List<Object?> get props => [];
}

class LeaveRequestLoading extends LeaveRequestState {
  const LeaveRequestLoading();
}

class LeaveRequestError extends LeaveRequestState {
  final String message;
  const LeaveRequestError(this.message);

  @override
  List<Object?> get props => [message];
}

class LeaveRequestData extends LeaveRequestState {
  final List<LeaveRequest> leaveRequest;
  const LeaveRequestData(this.leaveRequest);

  @override
  List<Object?> get props => [leaveRequest];
}

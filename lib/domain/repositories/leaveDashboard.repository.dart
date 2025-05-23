import 'package:staffsync/domain/model/leaveDashboard.model.dart';
import 'package:staffsync/domain/model/leaveRequest.model.dart';

abstract class LeaveDashboardRepository {
  Future<List<LeaveDashboard>> getLeaveDashboardStats(String token);
}

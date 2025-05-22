import 'package:staffsync/domain/model/leaveDashboard.model.dart';

abstract class LeaveDashboardRepository {
  Future<List<LeaveDashboard>> getLeaveDashboardStats(String token);
}

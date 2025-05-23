import 'package:staffsync/domain/model/leaveDashboard.model.dart';

abstract class ILeaveDashboardRemoteDatasource {
  Future<List<LeaveDashboard>> fetchLeaveDashboardStats(
    String token,
    String endpoint,
  );
}

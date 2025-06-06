import 'package:staffsync/domain/model/managerDashboard.model.dart';

abstract class IManagerDashboardRemoteDatasource {
  Future<List<Managerdashboard>> fetchManagerDashboardStats(
    String token,
    String endpoint,
  );
}

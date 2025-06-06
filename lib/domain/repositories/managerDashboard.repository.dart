import 'package:staffsync/domain/model/managerDashboard.model.dart';

abstract class ManagerdashboardRepository {
  Future<List<Managerdashboard>> getManagerDashboardStats(String token);
}
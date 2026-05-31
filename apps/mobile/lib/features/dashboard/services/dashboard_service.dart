import '../domain/operational_card.dart';
import '../repositories/dashboard_repository.dart';

class DashboardService {
  final DashboardRepository _repository = DashboardRepository();

  Future<OperationalMetrics> getOperationalMetrics({String? branchId}) async {
    return await _repository.getOperationalMetrics(branchId: branchId);
  }
}

final dashboardService = DashboardService();

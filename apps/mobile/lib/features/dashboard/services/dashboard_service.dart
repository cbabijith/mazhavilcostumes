import '../domain/operational_card.dart';
import '../domain/analytics_metrics.dart';
import '../repositories/dashboard_repository.dart';

class DashboardService {
  final DashboardRepository _repository = DashboardRepository();

  Future<OperationalMetrics> getOperationalMetrics({String? branchId}) async {
    return await _repository.getOperationalMetrics(branchId: branchId);
  }

  Future<AnalyticsMetrics> getAnalyticsMetrics({
    String? branchId,
    String range = 'this_week',
  }) async {
    return await _repository.getAnalyticsMetrics(
      branchId: branchId,
      range: range,
    );
  }
}

final dashboardService = DashboardService();

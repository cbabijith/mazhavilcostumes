import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../branches/viewmodels/providers/branch_provider.dart';
import '../../repositories/dashboard_repository.dart';
import '../../domain/operational_card.dart';

// Repository provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

// Dashboard metrics provider
final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final branchId = ref.watch(effectiveBranchIdProvider);
  return repo.getMetrics(branchId: branchId);
});

// Operational metrics provider
final operationalMetricsProvider = FutureProvider<OperationalMetrics>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final branchId = ref.watch(effectiveBranchIdProvider);
  print('[DashboardProvider] Fetching operational metrics with branchId: $branchId');
  try {
    return await repo.getOperationalMetrics(branchId: branchId);
  } catch (e) {
    print('[DashboardProvider] Error: $e');
    rethrow;
  }
});

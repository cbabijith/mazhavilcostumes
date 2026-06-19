import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/orders/viewmodels/providers/order_provider.dart';

class NavigationTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }
}

final navigationTabProvider = NotifierProvider<NavigationTabNotifier, int>(
  NavigationTabNotifier.new,
);

/// Helper to navigate to the Orders view and apply search/status/date filters
/// based on a query parameter URL (e.g. from dashboard cards).
void navigateToOrdersWithUrl(WidgetRef ref, String filterUrl) {
  final uri = Uri.parse(filterUrl);
  final params = uri.queryParametersAll;

  // Extract params
  final statusList = params['status'];
  final excludeStatusList = params['exclude_status'];
  final paymentStatusList = params['payment_status'];
  
  final dateFilter = (params['date_filter'] != null && params['date_filter']!.isNotEmpty)
      ? params['date_filter']!.first
      : 'ALL';
      
  final dateField = (params['date_field'] != null && params['date_field']!.isNotEmpty)
      ? params['date_field']!.first
      : null;
      
  final dateFrom = (params['date_from'] != null && params['date_from']!.isNotEmpty)
      ? params['date_from']!.first
      : null;
      
  final dateTo = (params['date_to'] != null && params['date_to']!.isNotEmpty)
      ? params['date_to']!.first
      : null;
      
  final hasStockConflict = params['has_stock_conflict'] != null &&
      params['has_stock_conflict']!.isNotEmpty &&
      params['has_stock_conflict']!.first == 'true';

  // Apply filters to orders notifier
  ref.read(ordersProvider.notifier).setFilters(
    status: statusList != null && statusList.length == 1 ? statusList.first : statusList,
    excludeStatus: excludeStatusList != null && excludeStatusList.length == 1 ? excludeStatusList.first : excludeStatusList,
    paymentStatus: paymentStatusList != null && paymentStatusList.length == 1 ? paymentStatusList.first : paymentStatusList,
    dateFilter: dateFilter,
    dateField: dateField,
    dateFrom: dateFrom,
    dateTo: dateTo,
    hasStockConflict: hasStockConflict ? true : null,
  );

  // Switch tab to Orders view (index 1)
  ref.read(navigationTabProvider.notifier).setTab(1);
}

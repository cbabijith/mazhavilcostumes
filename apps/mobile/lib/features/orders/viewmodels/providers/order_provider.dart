import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/providers/startup_cache_provider.dart';
import '../../../calendar/providers/calendar_provider.dart';
import '../../models/order.dart';
import '../../repositories/order_repository.dart';
import '../../../branches/viewmodels/providers/branch_provider.dart';
import '../../../dashboard/viewmodels/providers/dashboard_provider.dart';

// Repository provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

// Orders list provider and notifier
class OrdersNotifier extends StreamNotifier<PaginatedOrders> {
  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _currentSearch = '';
  dynamic _currentStatus;
  String? _currentBranchId;
  String _currentDateFilter = 'ALL';
  String? _currentDateFrom;
  String? _currentDateTo;
  dynamic _excludeStatus;
  String? _dateField;
  dynamic _paymentStatus;
  bool? _hasStockConflict;

  String? get currentStatus =>
      _currentStatus is String ? _currentStatus as String? : null;
  dynamic get currentStatusRaw => _currentStatus;
  String get currentDateFilter => _currentDateFilter;
  String? get currentDateFrom => _currentDateFrom;
  String? get currentDateTo => _currentDateTo;
  String get currentSearch => _currentSearch;

  CancelToken? _requestToken;
  int _generation = 0;
  bool _debounceSearch = false;

  @override
  Stream<PaginatedOrders> build() {
    _generation++;
    _currentPage = 1;
    _isLoadingMore = false;
    final token = CancelToken();
    _requestToken = token;
    ref.onDispose(token.cancel);
    final repo = ref.watch(orderRepositoryProvider);
    final scope = ref.watch(startupCacheScopeProvider);
    final cache = ref.watch(startupCacheProvider);
    final branchFuture = ref.watch(resolvedBranchIdProvider.future);
    final debounce = _debounceSearch;
    _debounceSearch = false;
    // Register dependencies/cancellation synchronously. An async* build would
    // defer these until subscription and allow superseded searches to start.
    Stream<PaginatedOrders> load() async* {
      try {
        if (debounce) await Future<void>.delayed(AppDurations.searchDebounce);
        if (token.isCancelled) return;
        final branchId = await branchFuture;
        if (token.isCancelled) return;
        _currentBranchId = branchId;
        if (scope != null && _isUnfiltered) {
          yield* repo.watchSavedOrders(
            cache: cache,
            scope: scope,
            branchId: branchId,
            limit: 15,
            cancelToken: token,
          );
        } else {
          yield await _getPage(repo, 1, token);
        }
      } on DioException catch (error) {
        if (!CancelToken.isCancel(error)) rethrow;
      }
    }

    return load();
  }

  bool get _isUnfiltered =>
      _currentSearch.isEmpty &&
      _currentStatus == null &&
      _currentDateFilter == 'ALL' &&
      _currentDateFrom == null &&
      _currentDateTo == null &&
      _excludeStatus == null &&
      _dateField == null &&
      _paymentStatus == null &&
      _hasStockConflict == null;

  Future<PaginatedOrders> _getPage(
    OrderRepository repo,
    int page,
    CancelToken? token,
  ) {
    return repo.getOrders(
      page: page,
      limit: 15,
      query: _currentSearch,
      status: _currentStatus,
      branchId: _currentBranchId,
      dateFilter: _currentDateFilter == 'ALL' ? null : _currentDateFilter,
      dateField: _dateField,
      dateFrom: _currentDateFrom,
      dateTo: _currentDateTo,
      excludeStatus: _excludeStatus,
      paymentStatus: _paymentStatus,
      hasStockConflict: _hasStockConflict,
      cancelToken: token,
    );
  }

  Future<void> _reload({bool debounce = false}) async {
    _debounceSearch = debounce;
    ref.invalidateSelf();
    try {
      await future;
    } catch (_) {
      // AsyncValue renders the error without an unhandled callback future.
    }
  }

  Future<void> search(String query) async {
    if (_currentSearch == query) return;
    _currentSearch = query;
    await _reload(debounce: true);
  }

  Future<void> filterByStatus(String? status) => setFilters(status: status);

  Future<void> filterByBranch(String? branchId) async {
    ref.read(selectedBranchIdProvider.notifier).select(branchId);
  }

  Future<void> filterByDate(
    String dateFilter, {
    String? dateFrom,
    String? dateTo,
  }) async {
    _currentDateFilter = dateFilter;
    _currentDateFrom = dateFrom;
    _currentDateTo = dateTo;
    _dateField = null;
    await _reload();
  }

  Future<void> setFilters({
    dynamic status,
    dynamic excludeStatus,
    dynamic paymentStatus,
    String dateFilter = 'ALL',
    String? dateField,
    String? dateFrom,
    String? dateTo,
    bool? hasStockConflict,
  }) async {
    _currentStatus = status;
    _excludeStatus = excludeStatus;
    _paymentStatus = paymentStatus;
    _currentDateFilter = dateFilter;
    _dateField = dateField;
    _currentDateFrom = dateFrom;
    _currentDateTo = dateTo;
    _hasStockConflict = hasStockConflict;
    await _reload();
  }

  Future<void> clearFilters() async {
    // Opening an already unfiltered tab must reuse its initial/cached request.
    if (_currentSearch.isEmpty &&
        _currentStatus == null &&
        _currentDateFilter == 'ALL' &&
        _currentDateFrom == null &&
        _currentDateTo == null &&
        _excludeStatus == null &&
        _dateField == null &&
        _paymentStatus == null &&
        _hasStockConflict == null) {
      return;
    }
    _currentSearch = '';
    await setFilters(); // Keep the branch selected by the signed-in user.
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || state.isLoading || !state.hasValue) return;
    final currentData = state.value!;
    if (currentData.savedAt != null) {
      return; // Never mix stale page 1 with live page 2.
    }
    if (_currentPage >= currentData.totalPages) return;
    final generation = _generation;
    _isLoadingMore = true;
    try {
      final nextPageData = await _getPage(
        ref.read(orderRepositoryProvider),
        _currentPage + 1,
        _requestToken,
      );
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      _currentPage = nextPageData.page;
      state = AsyncData(
        PaginatedOrders(
          orders: [...currentData.orders, ...nextPageData.orders],
          total: nextPageData.total,
          page: nextPageData.page,
          limit: nextPageData.limit,
          totalPages: nextPageData.totalPages,
          hasNext: nextPageData.hasNext,
          hasPrev: nextPageData.hasPrev,
          actionNeededCount: currentData.actionNeededCount,
          conflictCount: currentData.conflictCount,
        ),
      );
    } catch (_) {
      // Retain the loaded rows and let the next scroll retry.
    } finally {
      if (generation == _generation) _isLoadingMore = false;
    }
  }
}

final ordersProvider = StreamNotifierProvider<OrdersNotifier, PaginatedOrders>(
  () {
    return OrdersNotifier();
  },
);

// Single order provider - removed autoDispose for instant navigation back
final orderProvider = FutureProvider.family<Order, String>((ref, id) async {
  final repository = ref.watch(orderRepositoryProvider);
  final cancelToken = ref.watch(cancelTokenProvider);

  ref.keepAlive();
  return repository.getOrderById(id, cancelToken: cancelToken);
});

// Availability check provider
final availabilityCheckProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
      final repository = ref.watch(orderRepositoryProvider);
      final cancelToken = ref.watch(cancelTokenProvider);

      return repository.checkAvailability(
        items: params['items'] as List<Map<String, dynamic>>,
        startDate: params['startDate'] as String,
        endDate: params['endDate'] as String,
        branchId: params['branchId'] as String,
        excludeOrderId: params['excludeOrderId'] as String?,
        cancelToken: cancelToken,
      );
    });

// CancelToken provider for request cancellation
final cancelTokenProvider = Provider<CancelToken>((ref) {
  final token = CancelToken();
  ref.onDispose(() => token.cancel('Provider disposed'));
  return token;
});

// Order operations - simple function-based approach
class OrderOperations {
  final OrderRepository _repository;
  final void Function()? _onChanged;

  OrderOperations(this._repository, {void Function()? onChanged})
    : _onChanged = onChanged;

  Future<Order> getOrderById(String id) => _repository.getOrderById(id);

  Future<Order> createOrder(
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    final order = await _repository.createOrder(body, cancelToken: cancelToken);
    _onChanged?.call();
    return order;
  }

  Future<Order> updateOrder(
    String id,
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    final order = await _repository.updateOrder(
      id,
      body,
      cancelToken: cancelToken,
    );
    _onChanged?.call();
    return order;
  }

  Future<void> deleteOrder(String id, {CancelToken? cancelToken}) async {
    await _repository.deleteOrder(id, cancelToken: cancelToken);
    _onChanged?.call();
  }

  Future<Map<String, dynamic>> collectPayment({
    required String orderId,
    required double amount,
    required String paymentMode,
    String? paymentType,
    String? notes,
    CancelToken? cancelToken,
  }) async {
    final payment = await _repository.collectPayment(
      orderId: orderId,
      amount: amount,
      paymentMode: paymentMode,
      paymentType: paymentType,
      notes: notes,
      cancelToken: cancelToken,
    );
    _onChanged?.call();
    return payment;
  }

  Future<Order> processReturn({
    required String orderId,
    required List<Map<String, dynamic>> items,
    String? notes,
    double? lateFee,
    double? discount,
    CancelToken? cancelToken,
  }) async {
    final order = await _repository.processReturn(
      orderId: orderId,
      items: items,
      notes: notes,
      lateFee: lateFee,
      discount: discount,
      cancelToken: cancelToken,
    );
    _onChanged?.call();
    return order;
  }

  Future<Map<String, dynamic>> createDamageAssessment({
    required String orderId,
    required List<Map<String, dynamic>> damages,
    double? totalDamageAmount,
    String? notes,
    CancelToken? cancelToken,
  }) async {
    return await _repository.createDamageAssessment(
      orderId: orderId,
      damages: damages,
      totalDamageAmount: totalDamageAmount,
      notes: notes,
      cancelToken: cancelToken,
    );
  }

  Future<void> updatePayment({
    required String paymentId,
    required double amount,
    required String paymentMode,
    String? transactionId,
    String? notes,
  }) async {
    await _repository.updatePayment(
      paymentId: paymentId,
      amount: amount,
      paymentMode: paymentMode,
      transactionId: transactionId,
      notes: notes,
    );
    _onChanged?.call();
  }

  Future<void> deletePayment(String paymentId) async {
    await _repository.deletePayment(paymentId);
    _onChanged?.call();
  }

  Future<void> updateOrderItemDamage({
    required String itemId,
    required String conditionRating,
    String? damageDescription,
    required double damageCharges,
    required int damagedQuantity,
    CancelToken? cancelToken,
  }) async {
    await _repository.updateOrderItemDamage(
      itemId: itemId,
      conditionRating: conditionRating,
      damageDescription: damageDescription,
      damageCharges: damageCharges,
      damagedQuantity: damagedQuantity,
      cancelToken: cancelToken,
    );
    _onChanged?.call();
  }

  Future<Map<String, dynamic>> checkAvailability({
    required String startDate,
    required String endDate,
    required String branchId,
    required List<Map<String, dynamic>> items,
    String? excludeOrderId,
    CancelToken? cancelToken,
  }) async {
    return await _repository.checkAvailability(
      startDate: startDate,
      endDate: endDate,
      branchId: branchId,
      items: items,
      excludeOrderId: excludeOrderId,
      cancelToken: cancelToken,
    );
  }

  Future<Map<String, dynamic>> assessDamageUnit({
    required String orderId,
    required String assessmentId,
    required String decision,
    String? notes,
  }) async {
    return await _repository.assessDamageUnit(
      orderId: orderId,
      assessmentId: assessmentId,
      decision: decision,
      notes: notes,
    );
  }
}

final orderOperationsProvider = Provider<OrderOperations>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderOperations(
    repository,
    onChanged: () {
      if (!ref.mounted) return;
      // A settled return/payment must not leave old Revenue Due or pending cards.
      ref.invalidate(ordersProvider);
      ref.invalidate(calendarOrdersProvider);
      ref.invalidate(orderProvider);
      ref.invalidate(orderPaymentsProvider);
      ref.invalidate(dashboardMetricsProvider);
      ref.invalidate(operationalMetricsProvider);
      ref.invalidate(analyticsRequestProvider);
      ref.invalidate(analyticsMetricsProvider);
      ref.invalidate(categoryRevenueProvider);
      ref.invalidate(inventoryRoiProvider);
      ref.invalidate(transactionReportProvider);
    },
  );
});

final orderPaymentsProvider =
    FutureProvider.family<List<PaymentTransaction>, String>((ref, id) async {
      final repository = ref.watch(orderRepositoryProvider);
      print('[orderPaymentsProvider] Fetching payments for order ID: $id');
      try {
        final payments = await repository.getOrderPayments(id);
        print(
          '[orderPaymentsProvider] Fetched ${payments.length} payments for order ID: $id',
        );
        return payments;
      } catch (e, stack) {
        print(
          '[orderPaymentsProvider] Error fetching payments for order ID $id: $e',
        );
        print(stack);
        rethrow;
      }
    });

final orderDamageAssessmentsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
      final repository = ref.watch(orderRepositoryProvider);
      return await repository.getDamageAssessments(orderId);
    });

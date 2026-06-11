import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../models/order.dart';
import '../../repositories/order_repository.dart';

// Repository provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

// Orders list provider and notifier
class OrdersNotifier extends AsyncNotifier<PaginatedOrders> {
  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _currentSearch = '';
  String? _currentStatus;
  String? _currentBranchId;

  @override
  Future<PaginatedOrders> build() async {
    ref.keepAlive();
    _currentPage = 1;
    final repo = ref.watch(orderRepositoryProvider);
    return repo.getOrders(
      page: _currentPage,
      limit: 15, // Reduced from 25 for faster initial load
      query: _currentSearch,
      status: _currentStatus,
      branchId: _currentBranchId,
    );
  }

  Future<void> search(String query) async {
    _currentSearch = query;
    _currentPage = 1;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(orderRepositoryProvider);
      return repo.getOrders(
        page: _currentPage,
        limit: 15, // Reduced from 25 for faster initial load
        query: _currentSearch,
        status: _currentStatus,
        branchId: _currentBranchId,
      );
    });
  }

  Future<void> filterByStatus(String? status) async {
    _currentStatus = status;
    _currentPage = 1;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(orderRepositoryProvider);
      return repo.getOrders(
        page: _currentPage,
        limit: 15, // Reduced from 25 for faster initial load
        query: _currentSearch,
        status: _currentStatus,
        branchId: _currentBranchId,
      );
    });
  }

  Future<void> filterByBranch(String? branchId) async {
    _currentBranchId = branchId;
    _currentPage = 1;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(orderRepositoryProvider);
      return repo.getOrders(
        page: _currentPage,
        limit: 15, // Reduced from 25 for faster initial load
        query: _currentSearch,
        status: _currentStatus,
        branchId: _currentBranchId,
      );
    });
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !state.hasValue) return;

    final currentData = state.value!;
    if (_currentPage >= currentData.totalPages) return;

    _isLoadingMore = true;
    try {
      final repo = ref.read(orderRepositoryProvider);
      final nextPageData = await repo.getOrders(
        page: _currentPage + 1,
        limit: 15, // Reduced from 25 for faster initial load
        query: _currentSearch,
        status: _currentStatus,
        branchId: _currentBranchId,
      );

      _currentPage++;
      state = AsyncValue.data(PaginatedOrders(
        orders: [...currentData.orders, ...nextPageData.orders],
        total: nextPageData.total,
        page: nextPageData.page,
        limit: nextPageData.limit,
        totalPages: nextPageData.totalPages,
        hasNext: nextPageData.hasNext,
        hasPrev: nextPageData.hasPrev,
      ));
    } finally {
      _isLoadingMore = false;
    }
  }
}

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, PaginatedOrders>(() {
  return OrdersNotifier();
});

// Single order provider - removed autoDispose for instant navigation back
final orderProvider = FutureProvider.family<Order, String>((ref, id) async {
  final repository = ref.watch(orderRepositoryProvider);
  final cancelToken = ref.watch(cancelTokenProvider);
  
  ref.keepAlive();
  return repository.getOrderById(id, cancelToken: cancelToken);
});

// Availability check provider
final availabilityCheckProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
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

  OrderOperations(this._repository);

  Future<Order> createOrder(Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    return await _repository.createOrder(body, cancelToken: cancelToken);
  }

  Future<Order> updateOrder(String id, Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    return await _repository.updateOrder(id, body, cancelToken: cancelToken);
  }

  Future<void> deleteOrder(String id, {CancelToken? cancelToken}) async {
    await _repository.deleteOrder(id, cancelToken: cancelToken);
  }

  Future<Map<String, dynamic>> collectPayment({
    required String orderId,
    required double amount,
    required String paymentMode,
    String? notes,
    CancelToken? cancelToken,
  }) async {
    return await _repository.collectPayment(
      orderId: orderId,
      amount: amount,
      paymentMode: paymentMode,
      notes: notes,
      cancelToken: cancelToken,
    );
  }

  Future<Order> processReturn({
    required String orderId,
    required List<Map<String, dynamic>> items,
    String? notes,
    double? lateFee,
    double? discount,
    CancelToken? cancelToken,
  }) async {
    return await _repository.processReturn(
      orderId: orderId,
      items: items,
      notes: notes,
      lateFee: lateFee,
      discount: discount,
      cancelToken: cancelToken,
    );
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
    required String paymentMode,
    String? notes,
  }) async {
    await _repository.updatePayment(
      paymentId: paymentId,
      paymentMode: paymentMode,
      notes: notes,
    );
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
}

final orderOperationsProvider = Provider<OrderOperations>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderOperations(repository);
});

final orderPaymentsProvider = FutureProvider.family<List<PaymentTransaction>, String>((ref, id) async {
  final repository = ref.watch(orderRepositoryProvider);
  ref.keepAlive();
  return repository.getOrderPayments(id);
});


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../models/order.dart';
import '../../repositories/order_repository.dart';

// Repository provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

// Orders list provider
final ordersProvider = FutureProvider.autoDispose.family<PaginatedOrders, Map<String, dynamic>>((ref, params) async {
  final repository = ref.watch(orderRepositoryProvider);
  final cancelToken = ref.watch(cancelTokenProvider);
  
  return repository.getOrders(
    page: params['page'] ?? 1,
    limit: params['limit'] ?? 25,
    customerId: params['customerId'],
    branchId: params['branchId'],
    status: params['status'],
    query: params['query'],
    dateFilter: params['dateFilter'],
    dateFrom: params['dateFrom'],
    dateTo: params['dateTo'],
    cancelToken: cancelToken,
  );
});

// Single order provider
final orderProvider = FutureProvider.family.autoDispose<Order, String>((ref, id) async {
  final repository = ref.watch(orderRepositoryProvider);
  final cancelToken = ref.watch(cancelTokenProvider);
  
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
    required String paymentType,
    String? notes,
    CancelToken? cancelToken,
  }) async {
    return await _repository.collectPayment(
      orderId: orderId,
      amount: amount,
      paymentMode: paymentMode,
      paymentType: paymentType,
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
    required List<Map<String, dynamic>> items,
    String? notes,
    CancelToken? cancelToken,
  }) async {
    return await _repository.createDamageAssessment(
      orderId: orderId,
      items: items,
      notes: notes,
      cancelToken: cancelToken,
    );
  }
}

final orderOperationsProvider = Provider<OrderOperations>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderOperations(repository);
});

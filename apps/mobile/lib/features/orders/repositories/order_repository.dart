import 'package:dio/dio.dart';

import '../../../core/supabase/api_client.dart';
import '../models/order.dart';

class PaginatedOrders {
  final List<Order> orders;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;
  final int? actionNeededCount;
  final int? conflictCount;

  PaginatedOrders({
    required this.orders,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
    this.actionNeededCount,
    this.conflictCount,
  });
}

/// Repository layer for Orders communicating with Next.js API via Dio.
class OrderRepository {
  final _api = apiClient;

  /// Fetch all orders from Next.js API with pagination.
  Future<PaginatedOrders> getOrders({
    int page = 1,
    int limit = 25,
    String? customerId,
    String? branchId,
    String? status,
    String? query,
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    CancelToken? cancelToken,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (customerId != null && customerId.isNotEmpty) {
        queryParams['customer_id'] = customerId;
      }
      if (branchId != null && branchId.isNotEmpty) {
        queryParams['branch_id'] = branchId;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }
      if (dateFilter != null && dateFilter.isNotEmpty) {
        queryParams['date_filter'] = dateFilter;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams['date_from'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams['date_to'] = dateTo;
      }

      final response = await _api.get(
        '/orders',
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      final data = response.data;
      final ordersData = data['data'] as List<dynamic>? ?? [];
      final meta = data['meta'] as Map<String, dynamic>? ?? {};

      final orders = ordersData
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();

      return PaginatedOrders(
        orders: orders,
        total: meta['total'] as int? ?? 0,
        page: page,
        limit: limit,
        totalPages: meta['totalPages'] as int? ?? 1,
        hasNext: meta['hasNext'] as bool? ?? false,
        hasPrev: meta['hasPrev'] as bool? ?? false,
        actionNeededCount: meta['actionNeededCount'] as int?,
        conflictCount: meta['conflictCount'] as int?,
      );
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  /// Fetch a single order by ID.
  Future<Order> getOrderById(String id, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.get('/orders/$id', cancelToken: cancelToken);

      return Order.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load order: $e');
    }
  }

  /// Create a new order.
  Future<Order> createOrder(
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _api.post(
        '/orders',
        data: body,
        cancelToken: cancelToken,
      );

      return Order.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Update an existing order.
  Future<Order> updateOrder(
    String id,
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _api.patch(
        '/orders/$id',
        data: body,
        cancelToken: cancelToken,
      );

      return Order.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  /// Delete an order.
  Future<void> deleteOrder(String id, {CancelToken? cancelToken}) async {
    try {
      await _api.delete('/orders/$id', cancelToken: cancelToken);
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  /// Check availability for order items
  Future<Map<String, dynamic>> checkAvailability({
    required List<Map<String, dynamic>> items,
    required String startDate,
    required String endDate,
    required String branchId,
    String? excludeOrderId,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _api.post(
        '/orders/check-availability',
        data: {
          'items': items,
          'start_date': startDate,
          'end_date': endDate,
          'branch_id': branchId,
          'exclude_order_id': excludeOrderId,
        },
        options: Options(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
        cancelToken: cancelToken,
      );

      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to check availability: $e');
    }
  }

  /// Process returning of items in the order
  Future<Order> processReturn({
    required String orderId,
    required List<Map<String, dynamic>> items,
    String? notes,
    double? lateFee,
    double? discount,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _api.post(
        '/orders/$orderId/return',
        data: {
          'items': items,
          'notes': notes,
          'late_fee': lateFee,
          'discount': discount,
        },
        cancelToken: cancelToken,
      );

      return Order.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to process order return: $e');
    }
  }

  /// Collect payment for an order
  Future<Map<String, dynamic>> collectPayment({
    required String orderId,
    required double amount,
    required String paymentMode,
    String? paymentType,
    String? notes,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _api.post(
        '/orders/$orderId/payments',
        data: {
          'amount': amount,
          'payment_mode': paymentMode,
          'notes': notes,
          if (paymentType != null) 'payment_type': paymentType,
        },
        cancelToken: cancelToken,
      );

      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to collect payment: $e');
    }
  }

  /// Create damage assessment for an order
  Future<Map<String, dynamic>> createDamageAssessment({
    required String orderId,
    required List<Map<String, dynamic>> damages,
    double? totalDamageAmount,
    String? notes,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _api.post(
        '/orders/$orderId/damage-assessment',
        data: {
          'damages': damages,
          'total_damage_amount': totalDamageAmount,
          'notes': notes,
        },
        cancelToken: cancelToken,
      );

      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create damage assessment: $e');
    }
  }

  /// Fetch payments/transactions logged against the order.
  Future<List<PaymentTransaction>> getOrderPayments(
    String orderId, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _api.get(
        '/payments',
        queryParameters: {'order_id': orderId},
        cancelToken: cancelToken,
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => PaymentTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }

  /// Update an existing payment transaction's mode and notes.
  Future<void> updatePayment({
    required String paymentId,
    required String paymentMode,
    String? notes,
    CancelToken? cancelToken,
  }) async {
    try {
      await _api.patch(
        '/payments/$paymentId',
        data: {'payment_mode': paymentMode, 'notes': notes},
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  /// Update condition rating and damage assessment for a specific order item.
  Future<void> updateOrderItemDamage({
    required String itemId,
    required String conditionRating,
    String? damageDescription,
    required double damageCharges,
    required int damagedQuantity,
    CancelToken? cancelToken,
  }) async {
    try {
      await _api.patch(
        '/orders/items/$itemId/damage',
        data: {
          'condition_rating': conditionRating,
          'damage_description': damageDescription,
          'damage_charges': damageCharges,
          'damaged_quantity': damagedQuantity,
        },
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw Exception('Failed to update order item damage: $e');
    }
  }
}

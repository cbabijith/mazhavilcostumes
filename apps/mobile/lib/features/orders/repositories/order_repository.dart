import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../models/order.dart';

class PaginatedOrders {
  final List<Order> orders;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginatedOrders({
    required this.orders,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });
}

/// Repository layer for Orders communicating directly with Supabase.
class OrderRepository {
  final _supabase = Supabase.instance.client;

  /// Fetch all orders from Supabase with pagination.
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
  }) async {
    try {
      final fromIndex = (page - 1) * limit;
      final toIndex = fromIndex + limit - 1;

      // Base query fetching order, customer info, branch info, and order items.
      var dbQuery = _supabase.from('orders').select('''
        *,
        customer:customers(id, name, phone, alt_phone, email),
        branch:branches!branch_id(id, name),
        items:order_items(
          *,
          product:products(id, name, images)
        )
      ''');

      // Filter by customer
      if (customerId != null && customerId.isNotEmpty) {
        dbQuery = dbQuery.eq('customer_id', customerId);
      }

      // Filter by branch
      if (branchId != null && branchId.isNotEmpty) {
        dbQuery = dbQuery.eq('branch_id', branchId);
      }

      // Filter by status
      if (status != null && status.isNotEmpty) {
        if (status == 'late_return') {
          dbQuery = dbQuery.eq('is_late', true);
        } else {
          dbQuery = dbQuery.eq('status', status);
        }
      }

      // Filter by search query (notes)
      if (query != null && query.isNotEmpty) {
        dbQuery = dbQuery.or('notes.ilike.%$query%');
      }

      // Filter by dates
      if (dateFrom != null && dateFrom.isNotEmpty) {
        dbQuery = dbQuery.gte('start_date', dateFrom);
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        dbQuery = dbQuery.lte('end_date', dateTo);
      }

      final response = await dbQuery
          .order('created_at', ascending: false)
          .range(fromIndex, toIndex);

      print('DEBUG: ORDERS_RESPONSE: $response');

      final List<dynamic> data = response as List<dynamic>? ?? [];

      // Fetch Total Count using a lightweight ID select
      var countQuery = _supabase.from('orders').select('id');
      if (customerId != null && customerId.isNotEmpty) {
        countQuery = countQuery.eq('customer_id', customerId);
      }
      if (branchId != null && branchId.isNotEmpty) {
        countQuery = countQuery.eq('branch_id', branchId);
      }
      if (status != null && status.isNotEmpty) {
        if (status == 'late_return') {
          countQuery = countQuery.eq('is_late', true);
        } else {
          countQuery = countQuery.eq('status', status);
        }
      }
      if (query != null && query.isNotEmpty) {
        countQuery = countQuery.or('notes.ilike.%$query%');
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        countQuery = countQuery.gte('start_date', dateFrom);
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        countQuery = countQuery.lte('end_date', dateTo);
      }

      final countResult = await countQuery;
      final int totalCount = (countResult as List).length;
      final int totalPages = (totalCount / limit).ceil();

      return PaginatedOrders(
        orders: data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList(),
        total: totalCount,
        page: page,
        limit: limit,
        totalPages: totalPages > 0 ? totalPages : 1,
        hasNext: page < totalPages,
        hasPrev: page > 1,
      );
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  /// Fetch a single order by ID.
  Future<Order> getOrderById(String id) async {
    try {
      final response = await _supabase.from('orders').select('''
        *,
        customer:customers(id, name, phone, alt_phone, email),
        branch:branches!branch_id(id, name),
        items:order_items(
          *,
          product:products(id, name, images)
        )
      ''').eq('id', id).single();

      print('DEBUG: GET_ORDER_BY_ID_RESPONSE: $response');

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load order: $e');
    }
  }

  /// Create a new order.
  Future<Order> createOrder(Map<String, dynamic> body) async {
    try {
      final response = await _supabase.from('orders').insert(body).select().single();
      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Update an existing order.
  Future<Order> updateOrder(String id, Map<String, dynamic> body) async {
    try {
      final response = await _supabase.from('orders').update(body).eq('id', id).select().single();
      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  /// Delete an order.
  Future<void> deleteOrder(String id) async {
    try {
      await _supabase.from('orders').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  /// Record/collect a payment transaction for an order
  Future<void> collectPayment({
    required String orderId,
    required double amount,
    required String paymentMode,
    required String paymentType,
    String? notes,
  }) async {
    try {
      await _supabase.from('payments').insert({
        'order_id': orderId,
        'amount': amount,
        'payment_mode': paymentMode,
        'payment_type': paymentType,
        'notes': notes,
        'payment_date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to record payment: $e');
    }
  }

  /// Process returning of items in the order
  Future<void> processReturn({
    required String orderId,
    required List<Map<String, dynamic>> items,
    String? notes,
    double? lateFee,
    double? discount,
  }) async {
    try {
      final updates = {
        'status': 'returned',
        if (notes != null) 'notes': notes,
        if (lateFee != null) 'late_fee': lateFee,
        if (discount != null) 'discount': discount,
      };
      await _supabase.from('orders').update(updates).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to process order return: $e');
    }
  }

  /// Fetch payments/transactions logged against the order.
  Future<List<PaymentTransaction>> getOrderPayments(String orderId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*, staff:created_by(name)')
          .eq('order_id', orderId)
          .order('payment_date', ascending: false);
      final List<dynamic> data = response as List<dynamic>? ?? [];
      return data.map((e) => PaymentTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }

  /// Update an existing payment transaction's mode and notes.
  Future<void> updatePayment({
    required String paymentId,
    required String paymentMode,
    String? notes,
  }) async {
    try {
      await _supabase.from('payments').update({
        'payment_mode': paymentMode,
        'notes': notes,
      }).eq('id', paymentId);
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  /// Check availability of order items before starting rental.
  Future<Map<String, dynamic>> checkAvailability({
    required String startDate,
    required String endDate,
    required String branchId,
    required List<Map<String, dynamic>> items,
    String? excludeOrderId,
  }) async {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://mazhavilcostumes-admin.vercel.app/api',
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Get current auth token to pass to Next.js API
    final session = _supabase.auth.currentSession;
    if (session != null) {
      dio.options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }

    try {
      final response = await dio.post('/orders/check-availability', data: {
        'items': items,
        'start_date': startDate,
        'end_date': endDate,
        'branch_id': branchId,
        if (excludeOrderId != null) 'exclude_order_id': excludeOrderId,
      });

      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMsg = e.response?.data?['error'] ?? 'API availability check failed';
        throw Exception(errorMsg);
      }
      throw Exception('Failed to check availability: $e');
    }
  }
}


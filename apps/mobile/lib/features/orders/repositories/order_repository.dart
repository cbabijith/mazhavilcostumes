import 'package:supabase_flutter/supabase_flutter.dart';
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
        branch:branches(id, name),
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
        branch:branches(id, name),
        items:order_items(
          *,
          product:products(id, name, images)
        )
      ''').eq('id', id).single();

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
}

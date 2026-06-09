import 'package:dio/dio.dart';
import '../../../core/supabase/api_client.dart';
import '../models/customer.dart';

class PaginatedCustomers {
  final List<Customer> customers;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginatedCustomers({
    required this.customers,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });
}

/// Repository layer for Customers communicating with Next.js API via Dio.
class CustomerRepository {
  final _api = apiClient;

  /// Fetch all customers from Next.js API with pagination.
  Future<PaginatedCustomers> getCustomers({
    int page = 1,
    int limit = 20,
    String? query,
    String? phone,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    CancelToken? cancelToken,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }
      if (phone != null && phone.isNotEmpty) {
        queryParams['phone'] = phone;
      }

      final response = await _api.get(
        '/customers',
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      final data = response.data;
      final customersData = data['customers'] as List<dynamic>? ?? [];
      final total = data['total'] as int? ?? 0;
      final totalPages = (total / limit).ceil();

      return PaginatedCustomers(
        customers: customersData.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList(),
        total: total,
        page: page,
        limit: limit,
        totalPages: totalPages > 0 ? totalPages : 1,
        hasNext: page < totalPages,
        hasPrev: page > 1,
      );
    } catch (e) {
      throw Exception('Failed to load customers: $e');
    }
  }

  /// Fetch a single customer by ID.
  Future<Customer> getCustomerById(String id, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.get(
        '/customers/$id',
        cancelToken: cancelToken,
      );

      return Customer.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load customer: $e');
    }
  }

  /// Create a new customer.
  Future<Customer> createCustomer(Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.post(
        '/customers',
        data: body,
        cancelToken: cancelToken,
      );

      return Customer.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  /// Update an existing customer.
  Future<Customer> updateCustomer(String id, Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.patch(
        '/customers/$id',
        data: body,
        cancelToken: cancelToken,
      );

      return Customer.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  /// Delete a customer.
  Future<void> deleteCustomer(String id, {CancelToken? cancelToken}) async {
    try {
      await _api.delete(
        '/customers/$id',
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }
}

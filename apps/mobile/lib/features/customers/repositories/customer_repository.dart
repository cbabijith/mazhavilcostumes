import 'package:supabase_flutter/supabase_flutter.dart';
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

/// Repository layer for Customers communicating directly with Supabase.
class CustomerRepository {
  final _supabase = Supabase.instance.client;

  /// Fetch all customers from Supabase with pagination.
  Future<PaginatedCustomers> getCustomers({
    int page = 1,
    int limit = 20,
    String? query,
    String? phone,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    try {
      final fromIndex = (page - 1) * limit;
      final toIndex = fromIndex + limit - 1;

      var dbQuery = _supabase.from('customers').select('*');

      // Filter by search query (name or email)
      if (query != null && query.isNotEmpty) {
        dbQuery = dbQuery.or('name.ilike.%$query%,email.ilike.%$query%');
      }

      // Filter by phone
      if (phone != null && phone.isNotEmpty) {
        dbQuery = dbQuery.ilike('phone', '%$phone%');
      }

      final response = await dbQuery
          .order(sortBy, ascending: sortOrder == 'asc')
          .range(fromIndex, toIndex);

      final List<dynamic> data = response as List<dynamic>? ?? [];

      // Fetch Total Count using a lightweight ID select
      var countQuery = _supabase.from('customers').select('id');
      if (query != null && query.isNotEmpty) {
        countQuery = countQuery.or('name.ilike.%$query%,email.ilike.%$query%');
      }
      if (phone != null && phone.isNotEmpty) {
        countQuery = countQuery.ilike('phone', '%$phone%');
      }
      final countResult = await countQuery;
      final int totalCount = (countResult as List).length;
      final int totalPages = (totalCount / limit).ceil();

      return PaginatedCustomers(
        customers: data.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList(),
        total: totalCount,
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
  Future<Customer> getCustomerById(String id) async {
    try {
      final response = await _supabase.from('customers').select().eq('id', id).single();
      return Customer.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load customer: $e');
    }
  }

  /// Create a new customer.
  Future<Customer> createCustomer(Map<String, dynamic> body) async {
    try {
      final response = await _supabase.from('customers').insert(body).select().single();
      return Customer.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  /// Update an existing customer.
  Future<Customer> updateCustomer(String id, Map<String, dynamic> body) async {
    try {
      final response = await _supabase.from('customers').update(body).eq('id', id).select().single();
      return Customer.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  /// Delete a customer.
  Future<void> deleteCustomer(String id) async {
    try {
      await _supabase.from('customers').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }
}

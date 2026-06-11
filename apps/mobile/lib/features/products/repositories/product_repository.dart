import 'package:dio/dio.dart';
import '../../../core/supabase/api_client.dart';
import '../models/product.dart';
import '../models/product_analytics.dart';
import '../models/damage_record.dart';
import '../models/product_availability.dart';

class PaginatedProducts {
  final List<Product> products;
  final int total;
  final int page;
  final int totalPages;

  PaginatedProducts({
    required this.products,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}

/// Repository layer for Products communicating with Next.js API via Dio.
class ProductRepository {
  final _api = apiClient;

  /// Fetch all products from Next.js API with pagination.
  Future<PaginatedProducts> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? branchId,
    String? status,
    String? category,
    CancelToken? cancelToken,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['query'] = search;
      }
      if (branchId != null && branchId.isNotEmpty) {
        queryParams['branch_id'] = branchId;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category_id'] = category;
      }

      final response = await _api.get(
        '/products',
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      final data = response.data;
      
      // Handle both response structures: { success: true, data: { products: [...] } } and { products: [...] }
      final productsData = data['data']?['products'] as List<dynamic>? ?? 
                          data['products'] as List<dynamic>? ?? [];
      final total = data['data']?['total'] as int? ?? 
                   data['total'] as int? ?? 
                   productsData.length;
      final totalPages = (total / limit).ceil();

      return PaginatedProducts(
        products: productsData.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList(),
        total: total,
        page: page,
        totalPages: totalPages > 0 ? totalPages : 1,
      );
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  /// Fetch a single product by ID.
  Future<Product> getProductById(String id, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.get(
        '/products/$id',
        cancelToken: cancelToken,
      );

      final data = response.data['data'] ?? response.data;
      return Product.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }

  /// Create a new product.
  Future<Product> createProduct(Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.post(
        '/products',
        data: body,
        cancelToken: cancelToken,
      );

      final data = response.data['data'] ?? response.data;
      return Product.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Update an existing product.
  Future<Product> updateProduct(String id, Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.patch(
        '/products/$id',
        data: body,
        cancelToken: cancelToken,
      );

      final data = response.data['data'] ?? response.data;
      return Product.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Delete a product.
  Future<void> deleteProduct(String id, {CancelToken? cancelToken}) async {
    try {
      await _api.delete(
        '/products/$id',
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Fetch branch inventory for a product.
  Future<List<BranchInventory>> getProductBranchInventory(String productId, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.get(
        '/branch-inventory',
        queryParameters: {'product_id': productId},
        cancelToken: cancelToken,
      );

      final data = response.data;
      final list = data['data'] as List<dynamic>? ?? data as List<dynamic>? ?? [];
      return list.map((e) => BranchInventory.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch product analytics and rental history.
  Future<ProductAnalytics?> getProductAnalytics(String productId, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.get(
        '/products/$productId/orders',
        cancelToken: cancelToken,
      );

      return ProductAnalytics.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Fetch damage history for a product (admin-only endpoint).
  Future<List<DamageRecord>> getDamageHistory(String productId, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.get(
        '/products/$productId/damage-history',
        cancelToken: cancelToken,
      );

      final data = response.data as Map<String, dynamic>;
      final assessments = data['assessments'] as List<dynamic>? ?? [];
      return assessments.map((e) => DamageRecord.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Pre-delete safety check.
  Future<Map<String, dynamic>> canDeleteProduct(String id, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.get(
        '/products/$id/can-delete',
        cancelToken: cancelToken,
      );

      return response.data;
    } catch (e) {
      return {'canDelete': false, 'reason': 'Unable to check status: $e'};
    }
  }

  /// Get availability calendar for a product.
  /// Defaults to a 90-day window starting from today if no range is provided.
  Future<ProductAvailability?> getProductAvailability(
    String productId, {
    String? start,
    String? end,
    CancelToken? cancelToken,
  }) async {
    try {
      final now = DateTime.now();
      final effectiveStart = start ?? now.toIso8601String().split('T').first;
      final effectiveEnd = end ?? now.add(const Duration(days: 90)).toIso8601String().split('T').first;

      final response = await _api.get(
        '/products/$productId/availability',
        queryParameters: {
          'start': effectiveStart,
          'end': effectiveEnd,
        },
        cancelToken: cancelToken,
      );

      return ProductAvailability.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}

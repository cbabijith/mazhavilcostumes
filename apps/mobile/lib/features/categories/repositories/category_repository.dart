import 'package:dio/dio.dart';
import '../../../core/supabase/api_client.dart';
import '../models/category.dart';

/// Repository layer for Categories communicating with Next.js API via Dio.
class CategoryRepository {
  final _api = apiClient;

  /// Fetch all categories (sorted by sort_order, then name).
  Future<List<Category>> getCategories({CancelToken? cancelToken}) async {
    try {
      final response = await _api.get(
        '/categories',
        cancelToken: cancelToken,
      );

      final data = response.data as List<dynamic>? ?? [];
      return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  /// Fetch a single category by ID.
  Future<Category> getCategoryById(String id, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.get(
        '/categories/$id',
        cancelToken: cancelToken,
      );

      return Category.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load category: $e');
    }
  }

  /// Create a new category.
  Future<Category> createCategory(Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.post(
        '/categories',
        data: body,
        cancelToken: cancelToken,
      );

      return Category.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Update an existing category (partial update).
  Future<Category> updateCategory(String id, Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.patch(
        '/categories/$id',
        data: body,
        cancelToken: cancelToken,
      );

      return Category.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete a category (pre-checks should be done before calling this).
  Future<void> deleteCategory(String id, {CancelToken? cancelToken}) async {
    try {
      await _api.delete(
        '/categories/$id',
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Fetch counts of products per category from the server.
  Future<Map<String, int>> getCategoryProductCounts({CancelToken? cancelToken}) async {
    try {
      final response = await _api.get(
        '/categories/product-counts',
        cancelToken: cancelToken,
      );

      final data = response.data as Map<String, dynamic>? ?? {};
      return data.map((key, value) => MapEntry(key, (value as num).toInt()));
    } catch (e) {
      throw Exception('Failed to load category product counts: $e');
    }
  }

  /// Fetch total count of products in the store.
  Future<int> getTotalProductCount({CancelToken? cancelToken}) async {
    try {
      final response = await _api.get(
        '/products/count',
        cancelToken: cancelToken,
      );

      return response.data['count'] as int? ?? 0;
    } catch (e) {
      throw Exception('Failed to load total product count: $e');
    }
  }
}

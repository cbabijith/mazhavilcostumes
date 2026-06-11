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

      // Response structure: { success: true, data: [...] }
      final data = response.data['data'] as List<dynamic>? ?? [];
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
  /// If branchId is provided, returns counts filtered by branch.
  Future<Map<String, int>> getCategoryProductCounts({String? branchId, CancelToken? cancelToken}) async {
    try {
      final queryParameters = branchId != null ? {'branch_id': branchId} : null;
      final response = await _api.get(
        '/categories/product-counts',
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      // Response structure: { success: true, data: { "category_id": count, ... } }
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return data.map((key, value) => MapEntry(key, (value as num).toInt()));
    } catch (e) {
      // Return empty map on error to not block UI
      return {};
    }
  }

  /// Fetch total count of products in the store.
  /// NOTE: This endpoint doesn't exist in the current backend API.
  /// Use the total from the products list response instead.
  Future<int> getTotalProductCount({CancelToken? cancelToken}) async {
    // Backend endpoint doesn't exist - return 0, use products list total instead
    return 0;
  }
}

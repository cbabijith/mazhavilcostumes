import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

/// Repository layer for Categories communicating directly with Supabase.
class CategoryRepository {
  final _supabase = Supabase.instance.client;

  /// Fetch all categories (sorted by sort_order, then name).
  Future<List<Category>> getCategories({CancelToken? cancelToken}) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .order('sort_order', ascending: true)
          .order('name', ascending: true);

      final List<dynamic> data = response as List<dynamic>? ?? [];
      return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  /// Fetch a single category by ID.
  Future<Category> getCategoryById(String id, {CancelToken? cancelToken}) async {
    try {
      final response = await _supabase.from('categories').select().eq('id', id).single();
      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load category: $e');
    }
  }

  /// Create a new category.
  Future<Category> createCategory(Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    try {
      final response = await _supabase.from('categories').insert(body).select().single();
      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Update an existing category (partial update).
  Future<Category> updateCategory(String id, Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    try {
      final response = await _supabase.from('categories').update(body).eq('id', id).select().single();
      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete a category (pre-checks should be done before calling this).
  Future<void> deleteCategory(String id, {CancelToken? cancelToken}) async {
    try {
      await _supabase.from('categories').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Fetch counts of products per category from the server.
  Future<Map<String, int>> getCategoryProductCounts({CancelToken? cancelToken}) async {
    try {
      final List<dynamic> response = await _supabase
          .from('categories')
          .select('name, products:products!products_category_id_fkey(count)');

      final Map<String, int> counts = {};
      for (final row in response) {
        if (row is Map) {
          final name = row['name'] as String?;
          final products = row['products'];
          int count = 0;
          if (products is List && products.isNotEmpty) {
            final countVal = products.first['count'];
            if (countVal is num) {
              count = countVal.toInt();
            }
          } else if (products is Map && products.containsKey('count')) {
            final countVal = products['count'];
            if (countVal is num) {
              count = countVal.toInt();
            }
          }
          if (name != null && count > 0) {
            counts[name] = (counts[name] ?? 0) + count;
          }
        }
      }
      return counts;
    } catch (e) {
      throw Exception('Failed to load category product counts: $e');
    }
  }

  /// Fetch total count of products in the store.
  Future<int> getTotalProductCount({CancelToken? cancelToken}) async {
    try {
      final response = await _supabase
          .from('products')
          .select('id')
          .count(CountOption.exact);
      return response.count;
    } catch (e) {
      throw Exception('Failed to load total product count: $e');
    }
  }
}

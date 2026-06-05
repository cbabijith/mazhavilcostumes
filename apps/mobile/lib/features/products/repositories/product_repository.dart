import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

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

/// Repository layer for Products communicating directly with Supabase.
class ProductRepository {
  final _supabase = Supabase.instance.client;

  /// Fetch all products from Supabase with pagination.
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
      final fromIndex = (page - 1) * limit;
      final toIndex = fromIndex + limit - 1;

      // Base query fetching products, their categories, and inventory.
      final selectStr = category != null && category != 'All'
          ? '''
            *,
            category:categories!products_category_id_fkey!inner(name, gst_percentage),
            product_inventory(id, product_id, branch_id, quantity, available_quantity, low_stock_threshold, created_at, updated_at)
            '''
          : '''
            *,
            category:categories!products_category_id_fkey(name, gst_percentage),
            product_inventory(id, product_id, branch_id, quantity, available_quantity, low_stock_threshold, created_at, updated_at)
            ''';

      var query = _supabase.from('products').select(selectStr);

      // Apply search filters
      if (search != null && search.isNotEmpty) {
        query = query.or('name.ilike.%$search%,sku.ilike.%$search%');
      }

      // Filter by branch via product_inventory filter
      if (branchId != null && branchId.isNotEmpty) {
        query = query.filter('product_inventory.branch_id', 'eq', branchId);
      }

      // Filter by category
      if (category != null && category != 'All') {
        query = query.eq('categories.name', category);
      }

      // Fetch Paginated Data
      final response = await query
          .order('name', ascending: true)
          .range(fromIndex, toIndex);

      final List<dynamic> productsData = response as List<dynamic>? ?? [];

      // Fetch Total Count using count method to bypass 1000 record postgrest limit
      var countSelect = 'id';
      if (category != null && category != 'All') {
        countSelect = 'id, categories:categories!products_category_id_fkey!inner(name)';
      }
      var countQuery = _supabase.from('products').select(countSelect);

      if (search != null && search.isNotEmpty) {
        countQuery = countQuery.or('name.ilike.%$search%,sku.ilike.%$search%');
      }
      if (branchId != null && branchId.isNotEmpty) {
        countQuery = countQuery.filter('product_inventory.branch_id', 'eq', branchId);
      }
      if (category != null && category != 'All') {
        countQuery = countQuery.eq('categories.name', category);
      }

      final countResult = await countQuery.count(CountOption.exact);
      final int totalCount = countResult.count;
      final int totalPages = (totalCount / limit).ceil();

      return PaginatedProducts(
        products: productsData.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList(),
        total: totalCount,
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
      final response = await _supabase.from('products').select('''
        *,
        category:categories!products_category_id_fkey(name, gst_percentage),
        product_inventory(id, product_id, branch_id, quantity, available_quantity, low_stock_threshold, created_at, updated_at)
      ''').eq('id', id).single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }

  /// Create a new product.
  Future<Product> createProduct(Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    try {
      final response = await _supabase.from('products').insert(body).select().single();
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Update an existing product.
  Future<Product> updateProduct(String id, Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    try {
      final response = await _supabase.from('products').update(body).eq('id', id).select().single();
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Delete a product.
  Future<void> deleteProduct(String id, {CancelToken? cancelToken}) async {
    try {
      await _supabase.from('products').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Fetch branch inventory for a product.
  Future<List<BranchInventory>> getProductBranchInventory(String productId, {CancelToken? cancelToken}) async {
    try {
      final response = await _supabase.from('product_inventory').select().eq('product_id', productId);
      final List<dynamic> data = response as List<dynamic>? ?? [];
      return data.map((e) => BranchInventory.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Pre-delete safety check.
  Future<Map<String, dynamic>> canDeleteProduct(String id, {CancelToken? cancelToken}) async {
    try {
      final response = await _supabase
          .from('order_items')
          .select('id')
          .eq('product_id', id)
          .limit(1);
      final list = response as List<dynamic>? ?? [];
      final hasOrders = list.isNotEmpty;

      return {
        'canDelete': !hasOrders,
        'reason': hasOrders ? 'This product has active orders and cannot be deleted.' : null,
      };
    } catch (e) {
      return {'canDelete': false, 'reason': 'Unable to check status: $e'};
    }
  }

  /// Get availability calendar for a product
  Future<Map<String, dynamic>> getProductAvailability(
    String productId, {
    required String start,
    required String end,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _supabase
          .from('order_reservations')
          .select()
          .eq('product_id', productId)
          .gte('reserved_to', start.split('T')[0])
          .lte('reserved_from', end.split('T')[0]);

      return {
        'reservations': response,
      };
    } catch (e) {
      throw Exception('Failed to load availability: $e');
    }
  }
}

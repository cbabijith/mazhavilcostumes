import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../branches/viewmodels/providers/branch_provider.dart';
import '../../../categories/viewmodels/providers/category_provider.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';

/// Singleton repository instance.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

/// Status filter options for the product list.
enum ProductStatusFilter { all, available, lowStock, outOfStock }

/// Current active filter — UI reads/writes this.
class ProductStatusFilterNotifier extends Notifier<ProductStatusFilter> {
  @override
  ProductStatusFilter build() => ProductStatusFilter.all;

  void set(ProductStatusFilter filter) => state = filter;
}

final productStatusFilterProvider =
    NotifierProvider<ProductStatusFilterNotifier, ProductStatusFilter>(
        ProductStatusFilterNotifier.new);

/// Main products provider with pagination, search, and branch filtering.
class ProductsNotifier extends AsyncNotifier<PaginatedProducts> {
  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _currentSearch = '';
  String? _currentBranchId;

  @override
  Future<PaginatedProducts> build() async {
    // Keep data alive across tab switches to avoid re-fetching
    ref.keepAlive();
    _currentPage = 1;
    _currentBranchId = ref.watch(effectiveBranchIdProvider);
    final categoryName = ref.watch(productCategoryFilterProvider);
    final cancelToken = CancelToken();
    ref.onDispose(cancelToken.cancel);
    final repo = ref.watch(productRepositoryProvider);
    
    // Map category name to ID for API call
    String? categoryId;
    if (categoryName != 'All') {
      final categories = ref.read(categoriesProvider).value ?? [];
      final category = categories.firstWhere(
        (c) => c.name == categoryName,
        orElse: () => categories.first,
      );
      categoryId = category.id;
    }
    
    return repo.getProducts(
      page: _currentPage,
      search: _currentSearch,
      branchId: _currentBranchId,
      category: categoryId,
      cancelToken: cancelToken,
    );
  }

  Future<void> search(String query) async {
    _currentSearch = query;
    _currentPage = 1;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(productRepositoryProvider);
      final categoryName = ref.read(productCategoryFilterProvider);
      
      String? categoryId;
      if (categoryName != 'All') {
        final categories = ref.read(categoriesProvider).value ?? [];
        final category = categories.firstWhere(
          (c) => c.name == categoryName,
          orElse: () => categories.first,
        );
        categoryId = category.id;
      }
      
      return repo.getProducts(
        page: _currentPage,
        search: _currentSearch,
        branchId: _currentBranchId,
        category: categoryId,
      );
    });
  }

  Future<void> filterByBranch(String? branchId) async {
    _currentBranchId = branchId;
    _currentPage = 1;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(productRepositoryProvider);
      final categoryName = ref.read(productCategoryFilterProvider);
      
      String? categoryId;
      if (categoryName != 'All') {
        final categories = ref.read(categoriesProvider).value ?? [];
        final category = categories.firstWhere(
          (c) => c.name == categoryName,
          orElse: () => categories.first,
        );
        categoryId = category.id;
      }
      
      return repo.getProducts(
        page: _currentPage,
        search: _currentSearch,
        branchId: _currentBranchId,
        category: categoryId,
      );
    });
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !state.hasValue) return;

    final currentData = state.value!;
    if (currentData.page >= currentData.totalPages) return; // No more pages

    _isLoadingMore = true;
    try {
      final repo = ref.read(productRepositoryProvider);
      final categoryName = ref.read(productCategoryFilterProvider);
      
      String? categoryId;
      if (categoryName != 'All') {
        final categories = ref.read(categoriesProvider).value ?? [];
        final category = categories.firstWhere(
          (c) => c.name == categoryName,
          orElse: () => categories.first,
        );
        categoryId = category.id;
      }
      
      final nextPageData = await repo.getProducts(
        page: _currentPage + 1,
        search: _currentSearch,
        branchId: _currentBranchId,
        category: categoryId,
      );

      _currentPage++;
      state = AsyncValue.data(PaginatedProducts(
        products: [...currentData.products, ...nextPageData.products],
        total: nextPageData.total,
        page: nextPageData.page,
        totalPages: nextPageData.totalPages,
      ));
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    final repo = ref.read(productRepositoryProvider);
    final newProduct = await repo.createProduct(data);

    ref.invalidate(categoryProductCountsProvider);
    ref.invalidate(totalProductCountProvider);

    // Update local state immediately
    if (state.hasValue) {
      final currentData = state.value!;
      state = AsyncValue.data(PaginatedProducts(
        products: [newProduct, ...currentData.products],
        total: currentData.total + 1,
        page: currentData.page,
        totalPages: currentData.totalPages,
      ));
    } else {
      ref.invalidateSelf();
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    final repo = ref.read(productRepositoryProvider);
    final updatedProduct = await repo.updateProduct(id, data);

    ref.invalidate(categoryProductCountsProvider);

    // Update local state
    if (state.hasValue) {
      final currentData = state.value!;
      final list = currentData.products;
      final index = list.indexWhere((p) => p.id == id);
      if (index != -1) {
        final newList = [...list];
        newList[index] = updatedProduct;
        state = AsyncValue.data(PaginatedProducts(
          products: newList,
          total: currentData.total,
          page: currentData.page,
          totalPages: currentData.totalPages,
        ));
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final repo = ref.read(productRepositoryProvider);
    await repo.deleteProduct(id);

    ref.invalidate(categoryProductCountsProvider);
    ref.invalidate(totalProductCountProvider);

    // Update local state
    if (state.hasValue) {
      final currentData = state.value!;
      final list = currentData.products;
      state = AsyncValue.data(PaginatedProducts(
        products: list.where((p) => p.id != id).toList(),
        total: currentData.total - 1,
        page: currentData.page,
        totalPages: currentData.totalPages,
      ));
    }
  }
}

final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, PaginatedProducts>(() {
  return ProductsNotifier();
});

/// Fetches a single product by ID.
final productByIdProvider =
    FutureProvider.family<Product, String>((ref, id) async {
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);
  final repo = ref.read(productRepositoryProvider);
  return repo.getProductById(id, cancelToken: cancelToken);
});

/// Branch inventory for a product.
final productBranchInventoryProvider =
    FutureProvider.family<List<BranchInventory>, String>((ref, productId) async {
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);
  final repo = ref.read(productRepositoryProvider);
  return repo.getProductBranchInventory(productId, cancelToken: cancelToken);
});

class ProductCategoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void set(String category) => state = category;
}

/// Selected category filter. Default is 'All'.
final productCategoryFilterProvider =
    NotifierProvider<ProductCategoryFilterNotifier, String>(
        ProductCategoryFilterNotifier.new);

/// Derived provider: products filtered by the current category filter.
/// This simply returns the fetched paginated products directly (since the filtering
/// is now applied server-side on productsProvider).
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  return ref.watch(productsProvider).whenData((paginated) => paginated.products);
});

/// Fetches category product counts from the server.
/// Watches effectiveBranchIdProvider to update counts per branch.
final categoryProductCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  final branchId = ref.watch(effectiveBranchIdProvider);
  return repo.getCategoryProductCounts(branchId: branchId);
});

/// Dynamic category counts based on current filtered products
final filteredCategoryCountsProvider = Provider<Map<String, int>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  
  final products = productsAsync.value?.products ?? [];
  
  final Map<String, int> counts = {};
  
  // Count products by category
  for (final product in products) {
    if (product.categoryId != null) {
      counts[product.categoryId!] = (counts[product.categoryId!] ?? 0) + 1;
    }
  }
  
  // Add "All" count (total filtered products)
  counts['All'] = products.length;
  
  return counts;
});

/// Fetches the total count of products in the store from the server.
/// Queries ProductRepository with minimal parameters to get the database-wide total.
/// Watches effectiveBranchIdProvider to update count per branch.
final totalProductCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final branchId = ref.watch(effectiveBranchIdProvider);
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);
  
  final result = await repo.getProducts(
    page: 1,
    limit: 1,
    branchId: branchId,
    cancelToken: cancelToken,
  );
  
  return result.total;
});


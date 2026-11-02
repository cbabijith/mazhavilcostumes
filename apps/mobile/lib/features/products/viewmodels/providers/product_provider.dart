import 'package:dio/dio.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/providers/startup_cache_provider.dart';
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
      ProductStatusFilterNotifier.new,
    );

/// Main products provider with pagination, search, and branch filtering.
class ProductsNotifier extends StreamNotifier<PaginatedProducts> {
  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _currentSearch = '';
  String? _currentBranchId;

  CancelToken? _requestToken;
  int _generation = 0;
  bool _debounceSearch = false;
  String? _categoryId;

  @override
  Stream<PaginatedProducts> build() {
    _generation++;
    _currentPage = 1;
    _isLoadingMore = false;
    final token = CancelToken();
    _requestToken = token;
    ref.onDispose(token.cancel);
    final repo = ref.watch(productRepositoryProvider);
    final scope = ref.watch(startupCacheScopeProvider);
    final cache = ref.watch(startupCacheProvider);
    final categoryName = ref.watch(productCategoryFilterProvider);
    final categoriesFuture = categoryName != 'All'
        ? ref.watch(categoriesProvider.future)
        : null;
    final branchFuture = ref.watch(resolvedBranchIdProvider.future);
    final debounce = _debounceSearch;
    _debounceSearch = false;
    // Dependencies and cancellation must belong to this build, before the
    // stream subscribes; otherwise rapid filter changes can start duplicate GETs.
    Stream<PaginatedProducts> load() async* {
      try {
        if (debounce) await Future<void>.delayed(AppDurations.searchDebounce);
        if (token.isCancelled) return;
        final branchId = await branchFuture;
        if (token.isCancelled) return;
        _currentBranchId = branchId;
        _categoryId = null;
        if (categoryName != 'All') {
          final categories = await categoriesFuture!;
          if (token.isCancelled) return;
          for (final category in categories) {
            if (category.name == categoryName) {
              _categoryId = category.id;
              break;
            }
          }
        }
        if (scope != null && _currentSearch.isEmpty && categoryName == 'All') {
          yield* repo.watchSavedProducts(
            cache: cache,
            scope: scope,
            branchId: branchId,
            cancelToken: token,
          );
          return;
        }
        yield await repo.getProducts(
          page: _currentPage,
          search: _currentSearch,
          branchId: _currentBranchId,
          category: _categoryId,
          cancelToken: token,
        );
      } on DioException catch (error) {
        if (!CancelToken.isCancel(error)) rethrow;
      }
    }

    return load();
  }

  Future<void> _reload({bool debounce = false}) async {
    _debounceSearch = debounce;
    ref.invalidateSelf();
    try {
      await future;
    } catch (_) {
      // The provider exposes errors; callbacks must not leak unhandled futures.
    }
  }

  Future<void> search(String query) async {
    if (_currentSearch == query) return;
    _currentSearch = query;
    await _reload(debounce: true);
  }

  Future<void> filterByBranch(String? branchId) async {
    ref.read(selectedBranchIdProvider.notifier).select(branchId);
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || state.isLoading || !state.hasValue) return;
    final currentData = state.value!;
    if (currentData.savedAt != null) return;
    if (currentData.page >= currentData.totalPages) return;
    final generation = _generation;
    _isLoadingMore = true;
    try {
      final nextPageData = await ref
          .read(productRepositoryProvider)
          .getProducts(
            page: _currentPage + 1,
            search: _currentSearch,
            branchId: _currentBranchId,
            category: _categoryId,
            cancelToken: _requestToken,
          );
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      _currentPage = nextPageData.page;
      state = AsyncData(
        PaginatedProducts(
          products: [...currentData.products, ...nextPageData.products],
          total: nextPageData.total,
          page: nextPageData.page,
          totalPages: nextPageData.totalPages,
        ),
      );
    } catch (_) {
      // Keep the loaded page available; scrolling can retry a failed next page.
    } finally {
      if (generation == _generation) _isLoadingMore = false;
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
      state = AsyncValue.data(
        PaginatedProducts(
          products: [newProduct, ...currentData.products],
          total: currentData.total + 1,
          page: currentData.page,
          totalPages: currentData.totalPages,
        ),
      );
    }
    // Cancel any pre-mutation refresh so it cannot overwrite the saved change.
    ref.invalidateSelf();
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
        state = AsyncValue.data(
          PaginatedProducts(
            products: newList,
            total: currentData.total,
            page: currentData.page,
            totalPages: currentData.totalPages,
          ),
        );
      }
    }
    ref.invalidateSelf();
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
      state = AsyncValue.data(
        PaginatedProducts(
          products: list.where((p) => p.id != id).toList(),
          total: currentData.total - 1,
          page: currentData.page,
          totalPages: currentData.totalPages,
        ),
      );
    }
    ref.invalidateSelf();
  }
}

final productsProvider =
    StreamNotifierProvider<ProductsNotifier, PaginatedProducts>(() {
      return ProductsNotifier();
    });

/// Fetches a single product by ID.
final productByIdProvider = FutureProvider.family<Product, String>((
  ref,
  id,
) async {
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);
  final repo = ref.read(productRepositoryProvider);
  return repo.getProductById(id, cancelToken: cancelToken);
});

/// Branch inventory for a product.
final productBranchInventoryProvider =
    FutureProvider.family<List<BranchInventory>, String>((
      ref,
      productId,
    ) async {
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);
      final repo = ref.read(productRepositoryProvider);
      return repo.getProductBranchInventory(
        productId,
        cancelToken: cancelToken,
      );
    });

class ProductCategoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void set(String category) => state = category;
}

/// Selected category filter. Default is 'All'.
final productCategoryFilterProvider =
    NotifierProvider<ProductCategoryFilterNotifier, String>(
      ProductCategoryFilterNotifier.new,
    );

/// Derived provider: products filtered by the current category filter.
/// This simply returns the fetched paginated products directly (since the filtering
/// is now applied server-side on productsProvider).
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  return ref
      .watch(productsProvider)
      .whenData((paginated) => paginated.products);
});

/// Fetches category product counts from the server.
/// Watches effectiveBranchIdProvider to update counts per branch.
final categoryProductCountsProvider = FutureProvider<Map<String, int>>((
  ref,
) async {
  final repo = ref.watch(categoryRepositoryProvider);
  final token = CancelToken();
  ref.onDispose(token.cancel);
  final branchId = await ref.watch(resolvedBranchIdProvider.future);
  if (token.isCancelled) throw token.cancelError!;
  return repo.getCategoryProductCounts(branchId: branchId, cancelToken: token);
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

/// Reuse the counts response instead of downloading another product page.
final totalProductCountProvider = Provider<AsyncValue<int?>>((ref) {
  return ref
      .watch(categoryProductCountsProvider)
      .whenData((counts) => counts['All']);
});

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/product_analytics.dart';
import '../models/damage_record.dart';
import '../models/product_availability.dart';
import '../viewmodels/providers/product_provider.dart';

/// Bundled state for the product detail screen.
class ProductDetailsState {
  final Product product;
  final ProductAnalytics? analytics;
  final List<BranchInventory> branchInventory;
  final List<DamageRecord> damageHistory;
  final ProductAvailability? availability;

  const ProductDetailsState({
    required this.product,
    this.analytics,
    this.branchInventory = const [],
    this.damageHistory = const [],
    this.availability,
  });

  ProductDetailsState copyWith({
    Product? product,
    ProductAnalytics? analytics,
    List<BranchInventory>? branchInventory,
    List<DamageRecord>? damageHistory,
    ProductAvailability? availability,
  }) {
    return ProductDetailsState(
      product: product ?? this.product,
      analytics: analytics ?? this.analytics,
      branchInventory: branchInventory ?? this.branchInventory,
      damageHistory: damageHistory ?? this.damageHistory,
      availability: availability ?? this.availability,
    );
  }
}

/// Provider to fetch a single product with all supplementary data.
final productDetailsProvider =
    FutureProvider.family<ProductDetailsState, String>((ref, productId) async {
  final repo = ref.read(productRepositoryProvider);
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  // Fetch product first so we always have base data
  final product = await repo.getProductById(productId, cancelToken: cancelToken);

  // Parallel fetch for supplementary data
  final results = await Future.wait([
    repo.getProductBranchInventory(productId, cancelToken: cancelToken),
    repo.getProductAvailability(productId, cancelToken: cancelToken),
    repo.getProductAnalytics(productId, cancelToken: cancelToken),
    repo.getDamageHistory(productId, cancelToken: cancelToken),
  ]);

  return ProductDetailsState(
    product: product,
    branchInventory: results[0] as List<BranchInventory>,
    availability: results[1] as ProductAvailability?,
    analytics: results[2] as ProductAnalytics?,
    damageHistory: results[3] as List<DamageRecord>,
  );
});

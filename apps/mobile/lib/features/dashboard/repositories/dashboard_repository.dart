import 'package:dio/dio.dart';
import '../../../core/supabase/api_client.dart';
import '../domain/operational_card.dart';
import '../domain/analytics_metrics.dart';

class DashboardProduct {
  final String id;
  final String name;
  final double pricePerDay;
  final int availableQuantity;
  final String? imageUrl;
  final String? categoryName;
  final bool isActive;

  DashboardProduct({
    required this.id,
    required this.name,
    required this.pricePerDay,
    required this.availableQuantity,
    this.imageUrl,
    this.categoryName,
    required this.isActive,
  });

  factory DashboardProduct.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      final primaryImage = images.cast<dynamic>().firstWhere(
            (img) => img is Map && img['is_primary'] == true,
            orElse: () => images.first,
          );
      if (primaryImage is Map) {
        imageUrl = primaryImage['url'] as String?;
      } else if (primaryImage is String) {
        imageUrl = primaryImage;
      }
    }

    return DashboardProduct(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed product',
      pricePerDay: (json['price_per_day'] as num?)?.toDouble() ?? 0.0,
      availableQuantity: json['available_quantity'] as int? ?? 0,
      imageUrl: imageUrl,
      categoryName: json['category'] is Map ? json['category']['name'] as String? : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class DashboardMetrics {
  final double revenueToday;
  final double revenueThisWeek;
  final double revenueThisMonth;
  final double revenueChangeToday;
  final double revenueChangeThisWeek;
  final double revenueChangeThisMonth;
  final int newOrdersToday;
  final int newOrdersThisWeek;
  final int pendingOrders;
  final int overdueReturns;
  final int todaysPickups;
  final int todaysReturns;
  final int upcomingPickupsTomorrow;
  final int activeRentals;
  final int totalCustomers;
  final double depositsHeld;
  final int lowStockCount;
  final int damagedItemsCount;
  final int totalProducts;
  final int availableProducts;
  final int featuredProducts;
  final List<DashboardProduct> recentProducts;

  DashboardMetrics({
    required this.revenueToday,
    required this.revenueThisWeek,
    required this.revenueThisMonth,
    required this.revenueChangeToday,
    required this.revenueChangeThisWeek,
    required this.revenueChangeThisMonth,
    required this.newOrdersToday,
    required this.newOrdersThisWeek,
    required this.pendingOrders,
    required this.overdueReturns,
    required this.todaysPickups,
    required this.todaysReturns,
    required this.upcomingPickupsTomorrow,
    required this.activeRentals,
    required this.totalCustomers,
    required this.depositsHeld,
    required this.lowStockCount,
    required this.damagedItemsCount,
    required this.totalProducts,
    required this.availableProducts,
    required this.featuredProducts,
    required this.recentProducts,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final recentProductsList = (data['recentProducts'] ?? data['recent_products']) as List<dynamic>? ?? [];

    return DashboardMetrics(
      revenueToday: (data['revenueToday'] as num?)?.toDouble() ?? 0,
      revenueThisWeek: (data['revenueThisWeek'] as num?)?.toDouble() ?? 0,
      revenueThisMonth: (data['revenueThisMonth'] as num?)?.toDouble() ?? 0,
      revenueChangeToday: (data['revenueChangeToday'] as num?)?.toDouble() ?? 0,
      revenueChangeThisWeek: (data['revenueChangeThisWeek'] as num?)?.toDouble() ?? 0,
      revenueChangeThisMonth: (data['revenueChangeThisMonth'] as num?)?.toDouble() ?? 0,
      newOrdersToday: (data['newOrdersToday'] as num?)?.toInt() ?? 0,
      newOrdersThisWeek: (data['newOrdersThisWeek'] as num?)?.toInt() ?? 0,
      pendingOrders: (data['pendingOrders'] as num?)?.toInt() ?? 0,
      overdueReturns: (data['overdueReturns'] as num?)?.toInt() ?? 0,
      todaysPickups: (data['todaysPickups'] as num?)?.toInt() ?? 0,
      todaysReturns: (data['todaysReturns'] as num?)?.toInt() ?? 0,
      upcomingPickupsTomorrow: (data['upcomingPickupsTomorrow'] as num?)?.toInt() ?? 0,
      activeRentals: (data['activeRentals'] as num?)?.toInt() ?? 0,
      totalCustomers: (data['totalCustomers'] as num?)?.toInt() ?? 0,
      depositsHeld: (data['depositsHeld'] as num?)?.toDouble() ?? 0,
      lowStockCount: (data['lowStockCount'] as num?)?.toInt() ?? 0,
      damagedItemsCount: (data['damagedItemsCount'] as num?)?.toInt() ?? 0,
      totalProducts: (data['totalProducts'] as num?)?.toInt() ?? 0,
      availableProducts: (data['availableProducts'] as num?)?.toInt() ?? 0,
      featuredProducts: (data['featuredProducts'] as num?)?.toInt() ?? 0,
      recentProducts: recentProductsList
          .map((item) => DashboardProduct.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardRepository {
  final _api = apiClient;

  Future<DashboardMetrics> getMetrics({String? branchId, CancelToken? cancelToken}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (branchId != null && branchId.isNotEmpty) {
        queryParams['branch_id'] = branchId;
      }

      final response = await _api.get(
        '/dashboard/mobile-metrics',
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      return DashboardMetrics.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load dashboard metrics: $e');
    }
  }

  Future<OperationalMetrics> getOperationalMetrics({String? branchId, CancelToken? cancelToken}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (branchId != null && branchId.isNotEmpty) {
        queryParams['branch_id'] = branchId;
      }

      final response = await _api.get(
        '/dashboard/operational',
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      final responseData = response.data;
      final innerData = responseData['data'] as Map<String, dynamic>? ?? responseData;
      final cardsData = innerData['cards'] as List<dynamic>? ?? [];

      final cards = cardsData.map((cardData) {
        final card = cardData as Map<String, dynamic>;
        return OperationalCard(
          label: card['label'] as String? ?? '',
          orderCount: (card['orderCount'] as num?)?.toInt() ?? 0,
          icon: card['icon'] as String? ?? '',
          color: card['color'] as String? ?? '',
          filterUrl: card['filterUrl'] as String? ?? '',
          completedCount: (card['completedCount'] as num?)?.toInt(),
          totalCount: (card['totalCount'] as num?)?.toInt(),
          amount: (card['amount'] as num?)?.toDouble(),
        );
      }).toList();

      return OperationalMetrics(cards: cards);
    } catch (e) {
      throw Exception('Failed to load operational metrics: $e');
    }
  }

  Future<AnalyticsMetrics> getAnalyticsMetrics({
    String? branchId,
    String range = 'this_week',
    String categoryPeriod = 'month',
    int roiLimit = 5,
    CancelToken? cancelToken,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'range': range,
        'cat_period': categoryPeriod,
        'roi_limit': roiLimit,
      };
      if (branchId != null && branchId.isNotEmpty) {
        queryParams['branch_id'] = branchId;
      }

      final response = await _api.get(
        '/dashboard/mobile-analytics',
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      return AnalyticsMetrics.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load analytics metrics: $e');
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/operational_card.dart';

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
  final supabase = Supabase.instance.client;

  Future<DashboardMetrics> getMetrics({String? branchId}) async {
    // TODO: Implement using Supabase queries if needed
    throw UnimplementedError('getMetrics not implemented for Supabase direct access');
  }

  Future<OperationalMetrics> getOperationalMetrics({String? branchId}) async {
    try {
      // Get IST date context
      final now = DateTime.now();
      final istDateStr = DateTime(now.year, now.month, now.day).toIso8601String().split('T')[0];
      final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
      final yesterdayStr = DateTime(now.year, now.month, now.day - 1).toIso8601String().split('T')[0];
      final tomorrowStr = DateTime(now.year, now.month, now.day + 1).toIso8601String().split('T')[0];
      final next5DaysStr = DateTime(now.year, now.month, now.day + 5).toIso8601String().split('T')[0];

      print('[DashboardRepository] Calling Supabase RPC with branchId: $branchId');

      final response = await supabase.rpc('get_operational_dashboard_metrics', params: {
        'p_today_start': todayStart,
        'p_today_end': todayEnd,
        'p_today_date': istDateStr,
        'p_yesterday_date': yesterdayStr,
        'p_tomorrow_date': tomorrowStr,
        'p_next_5_days_date': next5DaysStr,
        'p_branch_id': branchId,
      });

      print('[DashboardRepository] RPC Response: $response');

      final rpcData = response as Map<String, dynamic>? ?? {
        'todaysBookings': 0,
        'todaysDeliveryTotal': 0,
        'todaysDeliveryDone': 0,
        'todaysReturnTotal': 0,
        'todaysReturnDone': 0,
        'prepareDeliveries': 0,
        'pendingDeliveries': 0,
        'pendingReturns': 0,
        'revenueDueCount': 0,
        'revenueDueAmount': 0,
      };

      final cards = [
        OperationalCard(
          label: "Today's Bookings",
          orderCount: (rpcData['todaysBookings'] as num?)?.toInt() ?? 0,
          icon: 'calendar-plus',
          color: 'blue',
          filterUrl: '',
        ),
        OperationalCard(
          label: "Today's Delivery",
          orderCount: (rpcData['todaysDeliveryTotal'] as num?)?.toInt() ?? 0,
          icon: 'truck',
          color: 'emerald',
          completedCount: (rpcData['todaysDeliveryDone'] as num?)?.toInt() ?? 0,
          totalCount: (rpcData['todaysDeliveryTotal'] as num?)?.toInt() ?? 0,
          filterUrl: '',
        ),
        OperationalCard(
          label: "Today's Return",
          orderCount: (rpcData['todaysReturnTotal'] as num?)?.toInt() ?? 0,
          icon: 'package-check',
          color: 'violet',
          completedCount: (rpcData['todaysReturnDone'] as num?)?.toInt() ?? 0,
          totalCount: (rpcData['todaysReturnTotal'] as num?)?.toInt() ?? 0,
          filterUrl: '',
        ),
        OperationalCard(
          label: "Prepare Delivery (5d)",
          orderCount: (rpcData['prepareDeliveries'] as num?)?.toInt() ?? 0,
          icon: 'boxes',
          color: 'amber',
          filterUrl: '',
        ),
        OperationalCard(
          label: "Pending Delivery",
          orderCount: (rpcData['pendingDeliveries'] as num?)?.toInt() ?? 0,
          icon: 'alert-triangle',
          color: 'rose',
          filterUrl: '',
        ),
        OperationalCard(
          label: "Pending Return",
          orderCount: (rpcData['pendingReturns'] as num?)?.toInt() ?? 0,
          icon: 'clock-alert',
          color: 'red',
          filterUrl: '',
        ),
        OperationalCard(
          label: "Revenue Due",
          orderCount: (rpcData['revenueDueCount'] as num?)?.toInt() ?? 0,
          amount: (rpcData['revenueDueAmount'] as num?)?.toDouble() ?? 0,
          icon: 'banknote',
          color: 'indigo',
          filterUrl: '',
        ),
      ];

      return OperationalMetrics(cards: cards);
    } catch (e) {
      print('[DashboardRepository] Error: $e');
      rethrow;
    }
  }
}

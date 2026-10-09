/// Top Costumes report row
///
/// Mirrors `TopCostumeRow` from the admin API
/// (`GET /api/reports/top-costumes`).
class TopCostume {
  final String productId;
  final String productName;
  final String categoryName;
  final int rentalCount;
  final double revenue;
  final int avgRentalDays;

  const TopCostume({
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.rentalCount,
    required this.revenue,
    required this.avgRentalDays,
  });

  factory TopCostume.fromJson(Map<String, dynamic> json) {
    return TopCostume(
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? 'Unnamed',
      categoryName: json['category_name'] as String? ?? '',
      rentalCount: (json['rental_count'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      avgRentalDays: (json['avg_rental_days'] as num?)?.toInt() ?? 0,
    );
  }
}

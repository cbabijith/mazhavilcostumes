/// Domain types for dashboard operational cards
class OperationalCard {
  final String label;
  final int orderCount;
  final String icon;
  final String color;
  final String filterUrl;
  final int? completedCount;
  final int? totalCount;
  final double? amount;

  OperationalCard({
    required this.label,
    required this.orderCount,
    required this.icon,
    required this.color,
    required this.filterUrl,
    this.completedCount,
    this.totalCount,
    this.amount,
  });

  factory OperationalCard.fromJson(Map<String, dynamic> json) {
    return OperationalCard(
      label: json['label'] as String? ?? '',
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      icon: json['icon'] as String? ?? '',
      color: json['color'] as String? ?? '',
      filterUrl: json['filterUrl'] as String? ?? '',
      completedCount: (json['completedCount'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
      amount: (json['amount'] as num?)?.toDouble(),
    );
  }

  /// Whether this is a progress card (delivery/return)
  bool get isProgressCard => completedCount != null && totalCount != null;

  /// Pending count for progress cards
  int get pendingCount => isProgressCard ? (totalCount! - completedCount!) : 0;

  /// Whether there are issues/warnings
  bool get hasWarning {
    if (isProgressCard) {
      return pendingCount > 0;
    }
    return orderCount > 0 && (icon == 'alert-triangle' || icon == 'clock-alert');
  }

  /// Status text to display
  String get statusText {
    if (isProgressCard) {
      if (totalCount == 0) return 'All clear';
      if (pendingCount > 0) {
        return '$pendingCount yet to ${label.contains('Delivery') ? 'deliver' : 'receive'}';
      }
      return 'All ${label.contains('Delivery') ? 'delivered' : 'received'} ✓';
    }
    if (amount != null) {
      if (amount == 0) return 'No outstanding dues ✓';
      return '$orderCount order${orderCount != 1 ? "s" : ""} pending balance';
    }
    if (orderCount == 0) return 'All clear';
    if (label.contains('Booking')) {
      return '$orderCount Booking${orderCount != 1 ? 's' : ''}';
    }
    return '$orderCount Order${orderCount != 1 ? 's' : ''}';
  }
}

class OperationalMetrics {
  final List<OperationalCard> cards;

  OperationalMetrics({required this.cards});
}

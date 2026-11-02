import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/reports_repository.dart';
import '../../domain/day_wise_booking.dart';
import '../../domain/top_costume.dart';

// Repository provider
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository();
});

/// Unique parameters for the day-wise booking report provider
class DayWiseBookingParam {
  final String fromDate;
  final String toDate;

  const DayWiseBookingParam({
    required this.fromDate,
    required this.toDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayWiseBookingParam &&
          runtimeType == other.runtimeType &&
          fromDate == other.fromDate &&
          toDate == other.toDate;

  @override
  int get hashCode => fromDate.hashCode ^ toDate.hashCode;
}

/// Fetches day-wise bookings for the given date range
final dayWiseBookingsProvider =
    FutureProvider.family<List<DayWiseBooking>, DayWiseBookingParam>((ref, param) async {
  final repo = ref.read(reportsRepositoryProvider);
  return repo.getDayWiseBookings(
    fromDate: param.fromDate,
    toDate: param.toDate,
  );
});

/// Ranking mode for the top costumes report
enum TopCostumeRank {
  count('count', 'By Rentals'),
  revenue('revenue', 'By Revenue');

  final String apiValue;
  final String label;
  const TopCostumeRank(this.apiValue, this.label);
}

/// Unique parameters for the top costumes report provider
class TopCostumesParam {
  final TopCostumeRank rank;
  final int limit;

  const TopCostumesParam({
    required this.rank,
    this.limit = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopCostumesParam &&
          runtimeType == other.runtimeType &&
          rank == other.rank &&
          limit == other.limit;

  @override
  int get hashCode => rank.hashCode ^ limit.hashCode;
}

/// Fetches top costumes for the given ranking mode
final topCostumesProvider =
    FutureProvider.family<List<TopCostume>, TopCostumesParam>((ref, param) async {
  final repo = ref.read(reportsRepositoryProvider);
  return repo.getTopCostumes(
    rankBy: param.rank.apiValue,
    limit: param.limit,
  );
});

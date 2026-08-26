import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listings_stats.dart';

class MyListingsStatsModel extends MyListingsStats {
  const MyListingsStatsModel({
    super.totalCount,
    super.approvedCount,
    super.pendingCount,
    super.rentedCount,
    super.rejectedCount,
    super.archivedCount,
  });

  factory MyListingsStatsModel.fromJson(Map<String, dynamic> json) {
    return MyListingsStatsModel(
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      approvedCount: (json['approved_count'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pending_count'] as num?)?.toInt() ?? 0,
      rentedCount: (json['rented_count'] as num?)?.toInt() ?? 0,
      rejectedCount: (json['rejected_count'] as num?)?.toInt() ?? 0,
      archivedCount: (json['archived_count'] as num?)?.toInt() ?? 0,
    );
  }
}

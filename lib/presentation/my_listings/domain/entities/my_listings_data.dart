import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listing_item.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listings_stats.dart';

class MyListingsData extends Equatable {
  const MyListingsData({required this.stats, required this.listings});

  final MyListingsStats stats;
  final List<MyListingItem> listings;

  static const empty = MyListingsData(
    stats: MyListingsStats.empty,
    listings: [],
  );

  @override
  List<Object?> get props => [stats, listings];
}

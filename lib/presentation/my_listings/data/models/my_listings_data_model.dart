import 'package:ideal_mobile/presentation/my_listings/data/models/my_listing_item_model.dart';
import 'package:ideal_mobile/presentation/my_listings/data/models/my_listings_stats_model.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listings_data.dart';

class MyListingsDataModel extends MyListingsData {
  const MyListingsDataModel({required super.stats, required super.listings});

  factory MyListingsDataModel.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : <String, dynamic>{};
    final rawListings = json['listings'] is List
        ? json['listings'] as List<dynamic>
        : <dynamic>[];

    return MyListingsDataModel(
      stats: MyListingsStatsModel.fromJson(statsJson),
      listings: rawListings
          .whereType<Map<String, dynamic>>()
          .map(MyListingItemModel.fromJson)
          .toList(),
    );
  }
}

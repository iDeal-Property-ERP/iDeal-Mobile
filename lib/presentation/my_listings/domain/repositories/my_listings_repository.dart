import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listings_data.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listings_stats.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class MyListingsRepository {
  ResultFuture<MyListingsStats> getMyListingsStats();

  ResultFuture<MyListingsData> getMyListings({String status = 'all'});
}

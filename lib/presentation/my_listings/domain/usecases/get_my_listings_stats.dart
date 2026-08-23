import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listings_stats.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/repositories/my_listings_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetMyListingsStats {
  const GetMyListingsStats(this._repository);

  final MyListingsRepository _repository;

  ResultFuture<MyListingsStats> call() => _repository.getMyListingsStats();
}

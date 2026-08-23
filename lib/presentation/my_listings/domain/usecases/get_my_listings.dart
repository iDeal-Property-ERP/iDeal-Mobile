import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listings_data.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/repositories/my_listings_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetMyListings {
  const GetMyListings(this._repository);

  final MyListingsRepository _repository;

  ResultFuture<MyListingsData> call([
    GetMyListingsParams params = const GetMyListingsParams(),
  ]) => _repository.getMyListings(status: params.status);
}

class GetMyListingsParams extends Equatable {
  const GetMyListingsParams({this.status = 'all'});

  final String status;

  @override
  List<Object?> get props => [status];
}

import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/favorites/domain/repositories/favorites_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class SetListingFavorite
    with UseCaseWithParams<void, SetListingFavoriteParams> {
  const SetListingFavorite(this._repository);

  final FavoritesRepository _repository;

  @override
  ResultVoid call(SetListingFavoriteParams params) {
    return _repository.setFavorite(
      listingId: params.listingId,
      isFavorite: params.isFavorite,
    );
  }
}

class SetListingFavoriteParams extends Equatable {
  const SetListingFavoriteParams({
    required this.listingId,
    required this.isFavorite,
  });

  final int listingId;
  final bool isFavorite;

  @override
  List<Object> get props => [listingId, isFavorite];
}

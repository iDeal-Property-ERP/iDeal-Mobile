import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/favorites/domain/repositories/favorites_repository.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetFavorites with UseCaseWithParams<ListingsPage, GetFavoritesParams> {
  const GetFavorites(this._repository);

  final FavoritesRepository _repository;

  @override
  ResultFuture<ListingsPage> call(GetFavoritesParams params) {
    return _repository.getFavorites(page: params.page, perPage: params.perPage);
  }
}

class GetFavoritesParams extends Equatable {
  const GetFavoritesParams({required this.page, this.perPage = 20});

  final int page;
  final int perPage;

  @override
  List<Object> get props => [page, perPage];
}

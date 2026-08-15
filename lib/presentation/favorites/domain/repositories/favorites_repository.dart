import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class FavoritesRepository {
  ResultFuture<ListingsPage> getFavorites({
    required int page,
    int perPage = 20,
  });

  ResultVoid setFavorite({required int listingId, required bool isFavorite});
}

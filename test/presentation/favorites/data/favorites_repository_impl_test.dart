import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:ideal_mobile/presentation/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:ideal_mobile/presentation/listings/data/models/listings_page_model.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesRemoteDataSource extends Mock
    implements FavoritesRemoteDataSource {}

void main() {
  late MockFavoritesRemoteDataSource dataSource;
  late FavoritesRepositoryImpl repository;

  const page = ListingsPageModel(
    items: [],
    count: 0,
    numPages: 0,
    perPage: 7,
    pageNumber: 2,
  );

  setUp(() {
    dataSource = MockFavoritesRemoteDataSource();
    repository = FavoritesRepositoryImpl(dataSource);
  });

  test('maps a favorites page success and forwards page/perPage', () async {
    when(
      () => dataSource.getFavorites(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer((_) async => page);

    final result = await repository.getFavorites(page: 2, perPage: 7);

    expect(result, const Right<Failure, ListingsPage>(page));
    verify(() => dataSource.getFavorites(page: 2, perPage: 7)).called(1);
  });

  test('maps a favorite mutation success to Right(null)', () async {
    when(
      () => dataSource.setFavorite(listingId: 12, isFavorite: true),
    ).thenAnswer((_) async {});

    final result = await repository.setFavorite(
      listingId: 12,
      isFavorite: true,
    );

    expect(result, const Right<Failure, void>(null));
  });

  test('maps a page API exception to APIFailure', () async {
    when(
      () => dataSource.getFavorites(page: 1),
    ).thenThrow(const APIException(message: 'Bad favorites', statusCode: 502));

    final result = await repository.getFavorites(page: 1);

    expect(
      result,
      const Left<Failure, ListingsPage>(
        APIFailure(message: 'Bad favorites', statusCode: 502),
      ),
    );
  });

  test('maps a mutation API exception to APIFailure', () async {
    when(
      () => dataSource.setFavorite(listingId: 12, isFavorite: false),
    ).thenThrow(
      const APIException(message: 'Could not remove', statusCode: 409),
    );

    final result = await repository.setFavorite(
      listingId: 12,
      isFavorite: false,
    );

    expect(
      result,
      const Left<Failure, void>(
        APIFailure(message: 'Could not remove', statusCode: 409),
      ),
    );
  });
}

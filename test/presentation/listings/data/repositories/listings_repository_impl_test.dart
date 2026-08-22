import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/listings/data/datasources/listings_remote_data_source.dart';
import 'package:ideal_mobile/presentation/listings/data/models/listing_filter_options_model.dart';
import 'package:ideal_mobile/presentation/listings/data/models/listings_page_model.dart';
import 'package:ideal_mobile/presentation/listings/data/repositories/listings_repository_impl.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:mocktail/mocktail.dart';

class MockListingsRemoteDataSource extends Mock
    implements ListingsRemoteDataSource {}

void main() {
  late MockListingsRemoteDataSource dataSource;
  late ListingsRepositoryImpl repository;

  const page = ListingsPageModel(
    items: [],
    count: 0,
    numPages: 0,
    perPage: 20,
    pageNumber: 1,
  );
  const options = ListingFilterOptionsModel();

  setUpAll(() {
    // mocktail needs a fallback instance for non-primitive types used with
    // any().
    registerFallbackValue(const ListingFilters.empty());
  });

  setUp(() {
    dataSource = MockListingsRemoteDataSource();
    repository = ListingsRepositoryImpl(dataSource);
  });

  test('returns Right on listings success', () async {
    when(
      () => dataSource.getListings(
        filters: any(named: 'filters'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer((_) async => page);

    final result = await repository.getListings(
      filters: const ListingFilters.empty(),
      page: 1,
    );

    expect(result, const Right<Failure, ListingsPage>(page));
  });

  test('returns Left APIFailure when listings fail', () async {
    when(
      () => dataSource.getListings(
        filters: any(named: 'filters'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenThrow(const APIException(message: 'Unavailable', statusCode: 503));

    final result = await repository.getListings(
      filters: const ListingFilters.empty(),
      page: 1,
    );

    expect(
      result,
      const Left<Failure, ListingsPage>(
        APIFailure(message: 'Unavailable', statusCode: 503),
      ),
    );
  });

  test('returns Right on filter options success', () async {
    when(() => dataSource.getFilterOptions()).thenAnswer((_) async => options);

    final result = await repository.getFilterOptions();

    expect(result, const Right<Failure, ListingFilterOptionsModel>(options));
  });
}

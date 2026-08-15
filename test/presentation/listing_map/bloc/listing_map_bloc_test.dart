import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listing_map/bloc/listing_map_bloc.dart';
import 'package:ideal_mobile/presentation/listing_map/bloc/listing_map_event.dart';
import 'package:ideal_mobile/presentation/listing_map/domain/entities/listing_map_result.dart';
import 'package:ideal_mobile/presentation/listing_map/domain/repositories/listing_map_repository.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements ListingMapRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(_bounds);
    registerFallbackValue(const ListingFilters.empty());
    registerFallbackValue(CancelToken());
  });

  test(
    'seeds coordinate cards and offers search only after user movement',
    () async {
      final repository = _MockRepository();
      when(
        () => repository.getListings(
          bounds: any(named: 'bounds'),
          filters: any(named: 'filters'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          ListingMapResult(items: [], count: 0, truncated: false),
        ),
      );
      final bloc = ListingMapBloc(repository: repository)
        ..add(
          InitializeListingMap(
            filters: const ListingFilters.empty(),
            seedListings: [_listing(1)],
          ),
        );
      await _settle();

      bloc.add(
        ListingMapCameraSettled(
          bounds: _bounds,
          reason: PropertyMapCameraMoveReason.programmatic,
        ),
      );
      await _settleProgrammaticCamera();
      expect(bloc.state.hasLoadedBounds, isTrue);
      expect(bloc.state.showSearchThisArea, isFalse);

      bloc.add(
        ListingMapCameraSettled(
          bounds: _movedBounds,
          reason: PropertyMapCameraMoveReason.gesture,
        ),
      );
      await _settle();
      expect(bloc.state.currentBounds, _movedBounds);
      expect(bloc.state.showSearchThisArea, isTrue);
      verify(
        () => repository.getListings(
          bounds: any(named: 'bounds'),
          filters: any(named: 'filters'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
      await bloc.close();
    },
  );

  test('cancels and suppresses an out-of-order response', () async {
    final repository = _MockRepository();
    final first = Completer<ListingMapResult>();
    final second = Completer<ListingMapResult>();
    var calls = 0;
    when(
      () => repository.getListings(
        bounds: any(named: 'bounds'),
        filters: any(named: 'filters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => Right(await (calls++ == 0 ? first.future : second.future)),
    );
    final bloc = ListingMapBloc(repository: repository)
      ..add(
        const InitializeListingMap(
          filters: ListingFilters.empty(),
          seedListings: [],
        ),
      );
    await _settle();
    bloc.add(
      ListingMapCameraSettled(
        bounds: _bounds,
        reason: PropertyMapCameraMoveReason.programmatic,
      ),
    );
    await _settleProgrammaticCamera();
    bloc.add(
      const ChangeListingMapFilters(ListingFilters(propertyType: 'house')),
    );
    await _settle();

    second.complete(
      ListingMapResult(items: [_listing(2)], count: 1, truncated: false),
    );
    await _settle();
    first.complete(
      ListingMapResult(items: [_listing(1)], count: 1, truncated: false),
    );
    await _settle();

    expect(bloc.state.items.single.id, 2);
    expect(bloc.state.filters.propertyType, 'house');
    await bloc.close();
  });

  test(
    'user gesture invalidates an active request and preserves area CTA',
    () async {
      final repository = _MockRepository();
      final pending = Completer<ListingMapResult>();
      when(
        () => repository.getListings(
          bounds: any(named: 'bounds'),
          filters: any(named: 'filters'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(await pending.future));
      final bloc = ListingMapBloc(repository: repository)
        ..add(
          InitializeListingMap(
            filters: const ListingFilters.empty(),
            seedListings: [_listing(1)],
          ),
        );
      await _settle();
      bloc.add(
        ListingMapCameraSettled(
          bounds: _bounds,
          reason: PropertyMapCameraMoveReason.programmatic,
        ),
      );
      await _settleProgrammaticCamera();

      bloc.add(
        ListingMapCameraSettled(
          bounds: _movedBounds,
          reason: PropertyMapCameraMoveReason.gesture,
        ),
      );
      await _settle();
      final token =
          verify(
                () => repository.getListings(
                  bounds: any(named: 'bounds'),
                  filters: any(named: 'filters'),
                  cancelToken: captureAny(named: 'cancelToken'),
                ),
              ).captured.single
              as CancelToken;
      expect(token.isCancelled, isTrue);
      expect(bloc.state.showSearchThisArea, isTrue);
      expect(bloc.state.isLoading, isFalse);

      pending.complete(
        ListingMapResult(items: [_listing(2)], count: 1, truncated: false),
      );
      await _settle();
      expect(bloc.state.items.single.id, 1);
      expect(bloc.state.showSearchThisArea, isTrue);
      await bloc.close();
    },
  );

  test('coalesces consecutive programmatic camera settlements', () async {
    final repository = _MockRepository();
    when(
      () => repository.getListings(
        bounds: any(named: 'bounds'),
        filters: any(named: 'filters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async =>
          const Right(ListingMapResult(items: [], count: 0, truncated: false)),
    );
    final bloc = ListingMapBloc(repository: repository)
      ..add(
        const InitializeListingMap(
          filters: ListingFilters.empty(),
          seedListings: [],
        ),
      );
    await _settle();

    bloc
      ..add(
        ListingMapCameraSettled(
          bounds: _bounds,
          reason: PropertyMapCameraMoveReason.programmatic,
        ),
      )
      ..add(
        ListingMapCameraSettled(
          bounds: _movedBounds,
          reason: PropertyMapCameraMoveReason.programmatic,
        ),
      );
    await _settleProgrammaticCamera();

    verify(
      () => repository.getListings(
        bounds: _movedBounds,
        filters: any(named: 'filters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
    await bloc.close();
  });

  test(
    'debounces search while clear refreshes current bounds immediately',
    () async {
      final repository = _MockRepository();
      when(
        () => repository.getListings(
          bounds: any(named: 'bounds'),
          filters: any(named: 'filters'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          ListingMapResult(items: [], count: 0, truncated: false),
        ),
      );
      final bloc = ListingMapBloc(repository: repository)
        ..add(
          const InitializeListingMap(
            filters: ListingFilters.empty(),
            seedListings: [],
          ),
        );
      await _settle();
      bloc.add(
        ListingMapCameraSettled(
          bounds: _bounds,
          reason: PropertyMapCameraMoveReason.gesture,
        ),
      );
      await _settle();

      bloc.add(const ChangeListingMapSearch('yu'));
      await Future<void>.delayed(const Duration(milliseconds: 250));
      bloc.add(const ChangeListingMapSearch('yunusobod'));
      await Future<void>.delayed(const Duration(milliseconds: 400));
      verifyNever(
        () => repository.getListings(
          bounds: any(named: 'bounds'),
          filters: any(named: 'filters'),
          cancelToken: any(named: 'cancelToken'),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 140));
      verify(
        () => repository.getListings(
          bounds: _bounds,
          filters: const ListingFilters(query: 'yunusobod'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);

      bloc.add(const ChangeListingMapSearch(''));
      await _settle();
      verify(
        () => repository.getListings(
          bounds: _bounds,
          filters: const ListingFilters.empty(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
      await bloc.close();
    },
  );

  test(
    'pan cancels pending search until search this area is requested',
    () async {
      final repository = _MockRepository();
      when(
        () => repository.getListings(
          bounds: any(named: 'bounds'),
          filters: any(named: 'filters'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          ListingMapResult(items: [], count: 0, truncated: false),
        ),
      );
      final bloc = ListingMapBloc(repository: repository)
        ..add(
          const InitializeListingMap(
            filters: ListingFilters.empty(),
            seedListings: [],
          ),
        );
      await _settle();
      bloc.add(
        ListingMapCameraSettled(
          bounds: _bounds,
          reason: PropertyMapCameraMoveReason.gesture,
        ),
      );
      await _settle();

      bloc.add(const ChangeListingMapSearch('yunusobod'));
      await Future<void>.delayed(const Duration(milliseconds: 250));
      bloc.add(
        ListingMapCameraSettled(
          bounds: _movedBounds,
          reason: PropertyMapCameraMoveReason.gesture,
        ),
      );
      await Future<void>.delayed(
        ListingMapBloc.searchDebounceDelay + const Duration(milliseconds: 40),
      );

      expect(bloc.state.filters.query, 'yunusobod');
      expect(bloc.state.currentBounds, _movedBounds);
      expect(bloc.state.showSearchThisArea, isTrue);
      verifyNever(
        () => repository.getListings(
          bounds: any(named: 'bounds'),
          filters: any(named: 'filters'),
          cancelToken: any(named: 'cancelToken'),
        ),
      );

      bloc.add(const SearchListingMapArea());
      await _settle();
      verify(
        () => repository.getListings(
          bounds: _movedBounds,
          filters: const ListingFilters(query: 'yunusobod'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
      await bloc.close();
    },
  );
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

Future<void> _settleProgrammaticCamera() => Future<void>.delayed(
  ListingMapBloc.programmaticSettleDelay + const Duration(milliseconds: 40),
);

final _bounds = PropertyMapBounds(
  southWest: const PropertyMapCoordinate(latitude: 41.2, longitude: 69.1),
  northEast: const PropertyMapCoordinate(latitude: 41.5, longitude: 69.4),
);

final _movedBounds = PropertyMapBounds(
  southWest: const PropertyMapCoordinate(latitude: 41.25, longitude: 69.15),
  northEast: const PropertyMapCoordinate(latitude: 41.55, longitude: 69.45),
);

ListingCard _listing(int id) => ListingCard(
  id: id,
  propertyId: id + 100,
  title: 'Home $id',
  district: 'Yunusobod',
  address: 'Tashkent',
  propertyType: 'apartment',
  rooms: 2,
  areaSqm: 60,
  floor: 3,
  totalFloors: 9,
  furnishing: 'furnished',
  price: 500,
  currency: 'USD',
  tariff: 'comfort',
  isVerified: true,
  isFeatured: false,
  score: 9,
  reviewCount: 1,
  coverImageUrl: null,
  mapLat: 41.31,
  mapLon: 69.28,
);

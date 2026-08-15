import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_feed.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../test_helpers.dart';

class MockListingsBloc extends MockBloc<ListingsEvent, ListingsState>
    implements ListingsBloc {}

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

class FakeListingsEvent extends Fake implements ListingsEvent {}

const secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeListingsEvent());
  });

  ListingCard listing(int id, {bool isFavorite = false}) => ListingCard(
    id: id,
    propertyId: id + 100,
    title: 'Listing $id',
    district: 'Yunusobod',
    address: 'Address $id',
    propertyType: 'apartment',
    rooms: 2,
    areaSqm: 68,
    floor: 4,
    totalFloors: 9,
    furnishing: 'furnished',
    price: 520,
    currency: 'USD',
    tariff: 'comfort',
    isVerified: true,
    isFeatured: false,
    score: 9.2,
    reviewCount: 14,
    coverImageUrl: null,
    mapLat: null,
    mapLon: null,
    isFavorite: isFavorite,
  );

  testWidgets('guest heart taps open the sign-in gate instead of toggling', (
    tester,
  ) async {
    final bloc = MockListingsBloc();
    when(() => bloc.state).thenReturn(
      ListingsState.test(items: [listing(1)], hasLoadedListings: true),
    );

    final prefs = MockSharedPreferencesAsync();
    when(() => prefs.getString(any())).thenAnswer((_) async => null);
    Prefs.setMockPrefs(prefs);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (_) async => null);

    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(secureStorageChannel, null);
    });

    await tester.runWidgetTest(
      providers: [BlocProvider<ListingsBloc>.value(value: bloc)],
      child: const Scaffold(
        body: CustomScrollView(slivers: [ListingsFeedSliver()]),
      ),
    );

    await tester.tap(find.byIcon(TablerIcons.heart).first);
    await tester.pumpAndSettle();

    expect(find.text('Make iDeal work for you'), findsOneWidget);
    expect(find.text('Sign in with phone'), findsOneWidget);
    verifyNever(() => bloc.add(any()));
  });
}

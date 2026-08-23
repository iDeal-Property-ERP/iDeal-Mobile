import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/my_listings/bloc/my_listings_bloc.dart';
import 'package:ideal_mobile/presentation/my_listings/bloc/my_listings_event.dart';
import 'package:ideal_mobile/presentation/my_listings/bloc/my_listings_state.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listing_item.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listings_stats.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_properties_card.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

class MockMyListingsBloc extends MockBloc<MyListingsEvent, MyListingsState>
    implements MyListingsBloc {}

Widget _wrap(Widget child, MyListingsBloc bloc) {
  return Sizer(
    builder: (context, orientation, screenType) {
      return MaterialApp(
        theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BlocProvider<MyListingsBloc>.value(
          value: bloc,
          child: Scaffold(body: child),
        ),
      );
    },
  );
}

void main() {
  group('ProfilePropertiesCard', () {
    testWidgets('shows loading skeleton while stats loading', (tester) async {
      final bloc = MockMyListingsBloc();
      when(() => bloc.state).thenReturn(
        const MyListingsState.initial().copyWith(isLoadingStats: true),
      );
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(const ProfilePropertiesCard(), bloc));
      await tester.pump();

      // Loading state shows shimmer placeholders, not real stat text
      expect(find.text('0'), findsNothing);
    });

    testWidgets('displays real stats counts', (tester) async {
      final bloc = MockMyListingsBloc();
      const stats = MyListingsStats(
        totalCount: 5,
        approvedCount: 3,
        pendingCount: 1,
        rentedCount: 1,
      );
      when(() => bloc.state).thenReturn(
        const MyListingsState.initial().copyWith(
          stats: stats,
          isLoadingStats: false,
        ),
      );
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(const ProfilePropertiesCard(), bloc));
      await tester.pumpAndSettle();

      // Status legend shows counts
      expect(find.textContaining('3'), findsWidgets);
      expect(find.textContaining('1'), findsWidgets);
    });

    testWidgets('hidden when total count is zero', (tester) async {
      final bloc = MockMyListingsBloc();
      when(() => bloc.state).thenReturn(const MyListingsState.initial());
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(const ProfilePropertiesCard(), bloc));
      await tester.pumpAndSettle();

      // Card renders nothing when totalCount == 0
      expect(find.byType(InkWell), findsNothing);
    });
  });

  group('ProfilePropertiesCard stats legend labels', () {
    testWidgets('renders status legend correctly in English', (tester) async {
      final bloc = MockMyListingsBloc();
      const stats = MyListingsStats(
        totalCount: 4,
        approvedCount: 2,
        pendingCount: 1,
        rentedCount: 1,
      );
      when(
        () => bloc.state,
      ).thenReturn(const MyListingsState.initial().copyWith(stats: stats));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, screenType) {
            return MaterialApp(
              locale: const Locale('en'),
              theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: BlocProvider<MyListingsBloc>.value(
                value: bloc,
                child: const Scaffold(body: ProfilePropertiesCard()),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Approved'), findsOneWidget);
      expect(find.textContaining('Pending'), findsOneWidget);
      expect(find.textContaining('Rented'), findsOneWidget);
    });
  });

  group('MyListingsBloc', () {
    test('initial state is correct', () {
      final bloc = MockMyListingsBloc();
      when(() => bloc.state).thenReturn(const MyListingsState.initial());

      final state = bloc.state;
      expect(state.selectedStatus, 'all');
      expect(state.listings, isEmpty);
      expect(state.stats.totalCount, 0);
      expect(state.isLoadingStats, false);
      expect(state.isLoadingListings, false);
    });

    test('copyWith clears error correctly', () {
      const state = MyListingsState(errorMessage: 'Something went wrong');
      final updated = state.copyWith(clearError: true);
      expect(updated.errorMessage, isNull);
    });

    test('MyListingItem status helpers', () {
      const approved = MyListingItem(
        propertyId: 1,
        title: 'Test',
        status: 'approved',
        statusDisplay: 'Approved',
      );
      expect(approved.isApproved, true);
      expect(approved.isPending, false);
      expect(approved.isRented, false);
      expect(approved.isRejected, false);

      const pending = MyListingItem(
        propertyId: 2,
        title: 'Test 2',
        status: 'pending',
        statusDisplay: 'Pending',
      );
      expect(pending.isPending, true);
      expect(pending.isApproved, false);
    });
  });
}

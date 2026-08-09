import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_bloc.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_event.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_state.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_amenities.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_body.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_not_found.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_shimmer.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_trust_card.dart';

import '../../test_helpers.dart';
import 'listing_detail_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ListingDetailBody', () {
    testWidgets('loading shows the listing detail shimmer', (tester) async {
      final bloc = mockListingDetailBloc(
        const ListingDetailState.test(isLoading: true),
      );

      await tester.runWidgetTest(
        child: const ListingDetailBody(listingId: 12),
        providers: [BlocProvider<ListingDetailBloc>.value(value: bloc)],
      );

      expect(find.byType(ListingDetailShimmer), findsOneWidget);
    });

    testWidgets('error shows a retryable error view', (tester) async {
      final bloc = mockListingDetailBloc(
        const ListingDetailState.test(errorMessage: 'Network unavailable'),
      );

      await tester.runWidgetTest(
        child: const ListingDetailBody(listingId: 12),
        providers: [BlocProvider<ListingDetailBloc>.value(value: bloc)],
      );

      expect(find.text('Network unavailable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      verify(() => bloc.add(const RetryListingDetailEvent(12))).called(1);
    });

    testWidgets(
      'loaded state renders title, price, spec chips, and amenities',
      (tester) async {
        final detail = buildListingDetail();
        final bloc = mockListingDetailBloc(
          ListingDetailState.test(detail: detail),
        );

        await tester.runWidgetTest(
          child: const ListingDetailBody(listingId: 12),
          providers: [BlocProvider<ListingDetailBloc>.value(value: bloc)],
        );
        await tester.pumpAndSettle();

        expect(find.text(detail.title), findsOneWidget);
        expect(find.text(r'$520'), findsOneWidget);
        expect(find.text('2 rooms'), findsOneWidget);
        expect(find.text('68 m²'), findsOneWidget);
        expect(find.text('Floor 4 of 9'), findsOneWidget);
        expect(find.text('Comfort'), findsOneWidget);
        expect(find.text('Wi-Fi'), findsOneWidget);
        expect(find.text('Furnished'), findsOneWidget);
      },
    );

    testWidgets(
      'trust and amenities sections are absent when their data is empty',
      (tester) async {
        final detail = buildListingDetail(
          amenities: const [],
          verificationChecklist: const [],
        );
        final bloc = mockListingDetailBloc(
          ListingDetailState.test(detail: detail),
        );

        await tester.runWidgetTest(
          child: const ListingDetailBody(listingId: 12),
          providers: [BlocProvider<ListingDetailBloc>.value(value: bloc)],
        );

        expect(find.byType(ListingDetailTrustCard), findsNothing);
        expect(find.byType(ListingDetailAmenities), findsNothing);
      },
    );

    testWidgets('loaded null detail shows the not-found view', (tester) async {
      final bloc = mockListingDetailBloc(const ListingDetailState.test());

      await tester.runWidgetTest(
        child: const ListingDetailBody(listingId: 12),
        providers: [BlocProvider<ListingDetailBloc>.value(value: bloc)],
      );

      expect(find.byType(ListingDetailNotFound), findsOneWidget);
      expect(find.text('This home is no longer available.'), findsOneWidget);
    });
  });
}

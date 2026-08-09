import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_bloc.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_state.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_about.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_amenities.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_body.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_neighborhood.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';

import '../../flutter_test_config.dart';
import '../../test_helpers.dart';
import 'listing_detail_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testExecutable(() {
    goldenTest(
      'Listing detail loaded screen light and dark themes',
      fileName: 'listing_detail_body',
      pumpBeforeTest: precacheImages,
      builder: () {
        final detail = buildListingDetail();
        final lightBloc = mockListingDetailBloc(
          ListingDetailState.test(detail: detail),
        );
        final darkBloc = mockListingDetailBloc(
          ListingDetailState.test(detail: detail),
        );

        return GoldenTestGroup(
          columnWidthBuilder: (_) => const FixedColumnWidth(pixel5DeviceWidth),
          children: [
            createTestScenario(
              name: 'listing_detail Light Theme',
              providers: [
                BlocProvider<ListingDetailBloc>.value(value: lightBloc),
              ],
              child: const ListingDetailBody(listingId: 12),
            ),
            createTestScenario(
              name: 'listing_detail Dark Theme',
              theme: AppThemeEnum.DarkTheme,
              providers: [
                BlocProvider<ListingDetailBloc>.value(value: darkBloc),
              ],
              child: const ListingDetailBody(listingId: 12),
            ),
          ],
        );
      },
    );

    // The body golden is clipped to the device viewport, so the sections that
    // sit below the fold get their own scenario.
    goldenTest(
      'Listing detail below-the-fold sections light and dark themes',
      fileName: 'listing_detail_sections',
      pumpBeforeTest: precacheImages,
      builder: () {
        final detail = buildListingDetail();
        Widget sections() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            ListingDetailAbout(description: detail.description!),
            ListingDetailAmenities(amenities: detail.amenities),
            ListingDetailNeighborhood(district: detail.district),
          ],
        );

        return GoldenTestGroup(
          columnWidthBuilder: (_) => const FixedColumnWidth(pixel5DeviceWidth),
          children: [
            createTestScenario(
              name: 'listing_detail sections Light Theme',
              addScaffold: true,
              child: sections(),
            ),
            createTestScenario(
              name: 'listing_detail sections Dark Theme',
              theme: AppThemeEnum.DarkTheme,
              addScaffold: true,
              child: sections(),
            ),
          ],
        );
      },
    );
  });
}

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart'
    as domain;
import 'package:ideal_mobile/presentation/listings/widgets/listing_card.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/services/guest_access_service.dart';
import 'package:ideal_mobile/utils/responsive.dart';
import 'package:ideal_mobile/widgets/images/prioritized_image_scheduler.dart';

/// Extra height reserved by a card's information block after its image.
///
/// At the 379 px Pixel-5 feed tile width, the image is about 205 px and the
/// three info rows plus padding measure about 109 px. This 116 px extent
/// leaves a small buffer for either theme's font metrics without overflowing.
const kListingInfoExtent = 116.0;

const kListingsGridSpacing = 16.0;
const kListingsFeedHorizontalPadding = 16.0;

typedef _ListingsFeedSelection = ({
  List<domain.ListingCard> items,
  bool isLoadingMore,
  bool isStale,
  String? listingRefreshError,
});

class ListingsFeedSliver extends StatelessWidget {
  const ListingsFeedSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final selection = context.select<ListingsBloc, _ListingsFeedSelection>(
      (bloc) => (
        items: bloc.state.items,
        isLoadingMore: bloc.state.isLoadingMore,
        isStale: bloc.state.isStale,
        listingRefreshError: bloc.state.listingRefreshError,
      ),
    );

    final grid = SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: kListingsFeedHorizontalPadding,
      ),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.crossAxisExtent;
          final count = listingColumns(availableWidth);
          final tileWidth =
              (availableWidth - kListingsGridSpacing * (count - 1)) / count;
          final mainAxisExtent = tileWidth * 210 / 388 + kListingInfoExtent;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              crossAxisSpacing: kListingsGridSpacing,
              mainAxisSpacing: kListingsGridSpacing,
              mainAxisExtent: mainAxisExtent,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final listing = selection.items[index];
              return ListingCardTile(
                key: keys.homePage.listingCardKey(listing.id),
                listing: listing,
                isFavorite: listing.isFavorite,
                onTap: () => context.router.push(
                  ListingDetailRoute(
                    listingId: listing.id,
                    initialListing: listing,
                  ),
                ),
                onFavoriteToggle: () {
                  unawaited(_toggleFavorite(context, listing.id));
                },
                imagePriority: index < count * 2
                    ? ImageLoadPriority.high
                    : ImageLoadPriority.normal,
              );
            }, childCount: selection.items.length),
          );
        },
      ),
    );
    if (!selection.isStale) return grid;

    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(child: _StaleListingsBanner()),
        grid,
      ],
    );
  }

  Future<void> _toggleFavorite(BuildContext context, int listingId) async {
    if (!await GuestAccessService.requireAuthentication(context)) return;
    if (!context.mounted) return;
    context.read<ListingsBloc>().add(ToggleFavoriteEvent(listingId));
  }
}

class _StaleListingsBanner extends StatelessWidget {
  const _StaleListingsBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: MaterialBanner(
        content: Text(context.localization.listings_showing_saved),
        actions: [
          TextButton(
            onPressed: () =>
                context.read<ListingsBloc>().add(const LoadListingsEvent()),
            child: Text(context.localization.listings_retry),
          ),
        ],
      ),
    );
  }
}

typedef ListingsFeed = ListingsFeedSliver;

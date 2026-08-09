import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart'
    as domain;
import 'package:ideal_mobile/presentation/listings/widgets/listing_card.dart';
import 'package:ideal_mobile/utils/responsive.dart';

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
  Set<int> favoriteIds,
});

class ListingsFeedSliver extends StatelessWidget {
  const ListingsFeedSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final selection = context.select<ListingsBloc, _ListingsFeedSelection>(
      (bloc) => (
        items: bloc.state.items,
        isLoadingMore: bloc.state.isLoadingMore,
        favoriteIds: bloc.state.favoriteIds,
      ),
    );

    return SliverPadding(
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
                listing: listing,
                isFavorite: selection.favoriteIds.contains(listing.id),
                onFavoriteToggle: () {
                  context.read<ListingsBloc>().add(
                    ToggleFavoriteEvent(listing.id),
                  );
                },
              );
            }, childCount: selection.items.length),
          );
        },
      ),
    );
  }
}

typedef ListingsFeed = ListingsFeedSliver;

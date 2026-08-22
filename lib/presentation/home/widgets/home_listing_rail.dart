import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart'
    as domain;
import 'package:ideal_mobile/presentation/listings/widgets/listing_card.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

const double kHomeRailCardWidth = 168.0;
const double kHomeRailHeight = 280.0;
const double kHomeRailSpacing = 10.0;

class HomeListingRail extends StatelessWidget {
  const HomeListingRail({
    super.key,
    required this.title,
    this.contextSubtitle,
    required this.listings,
    required this.onListingTap,
    required this.onFavoriteToggle,
  });

  final String title;
  final String? contextSubtitle;
  final List<domain.ListingCard> listings;
  final ValueChanged<domain.ListingCard> onListingTap;
  final ValueChanged<int> onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTextStyles.h2Bold.copyWith(
                  color: context.currentTheme.textNeutralPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (contextSubtitle != null && contextSubtitle!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  contextSubtitle!,
                  style: AppTextStyles.p3Regular.copyWith(
                    color: context.currentTheme.textNeutralSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: kHomeRailHeight,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: listings.length,
            separatorBuilder: (_, _) => const SizedBox(width: kHomeRailSpacing),
            itemBuilder: (context, index) {
              final listing = listings[index];
              return ListingCardTile(
                key: ValueKey('rail_listing_${listing.id}'),
                listing: listing,
                isFavorite: listing.isFavorite,
                width: kHomeRailCardWidth,
                isRail: true,
                onTap: () => onListingTap(listing),
                onFavoriteToggle: () => onFavoriteToggle(listing.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

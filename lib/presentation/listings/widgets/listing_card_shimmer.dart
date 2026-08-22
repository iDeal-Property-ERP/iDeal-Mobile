import 'package:flutter/material.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_feed.dart';
import 'package:ideal_mobile/utils/responsive.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/shimmer/shimmer_image.dart';
import 'package:ideal_mobile/widgets/shimmer/shimmer_text.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';
import 'package:shimmer/shimmer.dart';

class ListingCardShimmer extends StatelessWidget {
  const ListingCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.currentTheme.bgSurfaceBase2,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor3,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: context.currentTheme.bgNeutralLight100,
        highlightColor: context.currentTheme.bgNeutralLight50,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ShimmerImage(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerText(width: 140),
                    SizedBox(height: 4),
                    ShimmerText(width: 80),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerText(width: 60),
                        ShimmerText(width: 30),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListingCardShimmerGrid extends StatelessWidget {
  const ListingCardShimmerGrid({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
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
          final mainAxisExtent = tileWidth + kListingInfoExtent;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              crossAxisSpacing: kListingsGridSpacing,
              mainAxisSpacing: kListingsGridSpacing,
              mainAxisExtent: mainAxisExtent,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const ListingCardShimmer(),
              childCount: itemCount < 0 ? 0 : itemCount,
            ),
          );
        },
      ),
    );
  }
}

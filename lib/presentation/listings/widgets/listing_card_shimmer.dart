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
              aspectRatio: 388 / 210,
              child: ShimmerImage(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            SizedBox(
              height: kListingInfoExtent,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 32,
                      child: Row(
                        children: [
                          ShimmerText(width: 80),
                          Spacer(),
                          ShimmerText(width: 62),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    SizedBox(
                      height: 24,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ShimmerText(width: 180),
                      ),
                    ),
                    SizedBox(height: 4),
                    SizedBox(
                      height: 21,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ShimmerText(width: 260),
                      ),
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
          final mainAxisExtent = tileWidth * 210 / 388 + kListingInfoExtent;

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

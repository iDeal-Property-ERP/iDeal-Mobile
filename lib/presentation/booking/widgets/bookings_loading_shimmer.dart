import 'package:flutter/material.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/shimmer/shimmer_text.dart';
import 'package:shimmer/shimmer.dart';

class BookingsLoadingShimmer extends StatelessWidget {
  const BookingsLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.currentTheme.bgNeutralLight200,
      highlightColor: context.currentTheme.bgNeutralLight100,
      child: ListView.separated(
        itemCount: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        separatorBuilder: (_, _) => const SizedBox(height: 12.0),
        itemBuilder: (_, _) => const _BookingCardSkeleton(),
      ),
    );
  }
}

class _BookingCardSkeleton extends StatelessWidget {
  const _BookingCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: context.currentTheme.strokeNeutralLight200),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Container(
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              color: context.currentTheme.bgShadesWhite,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                const ShimmerText(width: double.infinity),
                const SizedBox(height: 6.0),
                ShimmerText(width: MediaQuery.of(context).size.width * 0.4),
                const SizedBox(height: 12.0),
                ShimmerText(width: MediaQuery.of(context).size.width * 0.5),
                const SizedBox(height: 12.0),
                ShimmerText(width: MediaQuery.of(context).size.width * 0.25),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

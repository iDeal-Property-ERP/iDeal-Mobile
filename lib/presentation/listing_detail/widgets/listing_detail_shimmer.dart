import 'package:flutter/material.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/shimmer/shimmer_button.dart';
import 'package:ideal_mobile/widgets/shimmer/shimmer_content.dart';
import 'package:ideal_mobile/widgets/shimmer/shimmer_image.dart';
import 'package:ideal_mobile/widgets/shimmer/shimmer_text.dart';
import 'package:shimmer/shimmer.dart';

class ListingDetailShimmer extends StatelessWidget {
  const ListingDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.currentTheme.bgNeutralLight100,
      highlightColor: context.currentTheme.bgNeutralLight50,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ShimmerImage(width: double.infinity, height: 300),
                  SizedBox(
                    height: 76,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 12,
                        right: 16,
                        bottom: 4,
                      ),
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, __) =>
                          const ShimmerImage(width: 84, height: 60, radius: 10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const ShimmerText(width: 160),
                            const Spacer(),
                            const ShimmerContent(
                              width: 82,
                              height: 28,
                              radius: 999,
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        const ShimmerText(width: 250),
                        const SizedBox(height: 6),
                        const ShimmerText(width: 190),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            const ShimmerContent(
                              width: 92,
                              height: 38,
                              radius: 8,
                            ),
                            const ShimmerContent(
                              width: 88,
                              height: 38,
                              radius: 8,
                            ),
                            const ShimmerContent(
                              width: 105,
                              height: 38,
                              radius: 8,
                            ),
                            const ShimmerContent(
                              width: 98,
                              height: 38,
                              radius: 8,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const ShimmerContent(
                          width: double.infinity,
                          height: 138,
                          radius: 16,
                        ),
                        const SizedBox(height: 14),
                        const ShimmerText(width: 145),
                        const SizedBox(height: 8),
                        const ShimmerContent(
                          width: double.infinity,
                          height: 72,
                          radius: 4,
                        ),
                        const SizedBox(height: 14),
                        const ShimmerText(width: 185),
                        const SizedBox(height: 13),
                        const ShimmerContent(
                          width: double.infinity,
                          height: 62,
                          radius: 4,
                        ),
                        const SizedBox(height: 14),
                        const ShimmerContent(
                          width: double.infinity,
                          height: 46,
                          radius: 4,
                        ),
                        const SizedBox(height: 14),
                        const ShimmerText(width: 250),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.currentTheme.bgSurfaceBase2,
              border: Border(
                top: BorderSide(
                  color: context.currentTheme.strokeNeutralLight100,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: ShimmerText(width: 112),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: ShimmerButton(height: 48, radius: 12),
                        ),
                        const SizedBox(width: 12),
                        const ShimmerButton(width: 48, height: 48, radius: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

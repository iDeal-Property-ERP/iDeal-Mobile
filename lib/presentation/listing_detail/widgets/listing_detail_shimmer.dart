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
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, _) =>
                          const ShimmerImage(width: 84, height: 60, radius: 10),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            ShimmerText(width: 160),
                            Spacer(),
                            ShimmerContent(width: 82, height: 28, radius: 999),
                          ],
                        ),
                        SizedBox(height: 9),
                        ShimmerText(width: 250),
                        SizedBox(height: 6),
                        ShimmerText(width: 190),
                        SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ShimmerContent(width: 92, height: 38, radius: 8),
                            ShimmerContent(width: 88, height: 38, radius: 8),
                            ShimmerContent(width: 105, height: 38, radius: 8),
                            ShimmerContent(width: 98, height: 38, radius: 8),
                          ],
                        ),
                        SizedBox(height: 14),
                        ShimmerContent(
                          width: double.infinity,
                          height: 138,
                          radius: 16,
                        ),
                        SizedBox(height: 14),
                        ShimmerText(width: 145),
                        SizedBox(height: 8),
                        ShimmerContent(
                          width: double.infinity,
                          height: 72,
                          radius: 4,
                        ),
                        SizedBox(height: 14),
                        ShimmerText(width: 185),
                        SizedBox(height: 13),
                        ShimmerContent(
                          width: double.infinity,
                          height: 62,
                          radius: 4,
                        ),
                        SizedBox(height: 14),
                        ShimmerContent(
                          width: double.infinity,
                          height: 46,
                          radius: 4,
                        ),
                        SizedBox(height: 14),
                        ShimmerText(width: 250),
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
            child: const SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ShimmerText(width: 112),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: ShimmerButton(height: 48, radius: 12)),
                        SizedBox(width: 12),
                        ShimmerButton(width: 48, height: 48, radius: 12),
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

import 'package:flutter/material.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';
import 'package:shimmer/shimmer.dart';

class ChatListShimmer extends StatelessWidget {
  const ChatListShimmer({super.key, this.itemCount = 7});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 1),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: context.currentTheme.bgNeutralLight200,
          highlightColor: context.currentTheme.bgNeutralLight100,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _ShimmerBox(width: 56, height: 56, radius: AppRadius.input),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(
                        width: 170,
                        height: 14,
                        radius: AppRadius.input / 2,
                      ),
                      SizedBox(height: 8),
                      _ShimmerBox(
                        width: 120,
                        height: 12,
                        radius: AppRadius.input / 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                _ShimmerBox(width: 38, height: 12, radius: AppRadius.input / 2),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.currentTheme.bgNeutralLight100,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

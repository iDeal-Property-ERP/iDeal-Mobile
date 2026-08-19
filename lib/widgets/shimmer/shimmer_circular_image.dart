import 'package:flutter/cupertino.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:sizer/sizer.dart';

class ShimmerCircularImage extends StatelessWidget {
  const ShimmerCircularImage({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular((size / 2).w),
      child: Container(
        height: size.w,
        width: size.w,
        color: context.currentTheme.bgShadesWhite,
      ),
    );
  }
}

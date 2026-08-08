import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';

class EmptyWishlistView extends StatelessWidget {
  const EmptyWishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          SvgPicture.asset(Assets.icons.emptyWishlist, height: 195, width: 195),
          const SizedBox(height: 24),
          Text(
            context.localization.empty_wishlist_title,
            style: AppTextStyles.p1SemiBold.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.localization.empty_wishlist_message,
            style: AppTextStyles.p3Regular.copyWith(
              color: context.currentTheme.textNeutralSecondary,
            ),
            textAlign: .center,
          ),
          const SizedBox(height: 30),
          AppButton(
            label: context.localization.explore_products,
            foregroundColor: context.currentTheme.textNeutralLight,
            onPressed: () {},
            size: AppButtonSize.extraLarge,
          ),
        ],
      ),
    );
  }
}

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/empty_saved_cards/widgets/empty_saved_cards_app_bar.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';

@RoutePage()
class EmptySavedCardScreen extends StatelessWidget {
  const EmptySavedCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EmptySavedCardAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              SvgPicture.asset(
                Assets.icons.emptySavedCards,
                height: 195,
                width: 195,
              ),
              const SizedBox(height: 24),
              Text(
                context.localization.empty_cards_list_title,
                style: AppTextStyles.p1SemiBold.copyWith(
                  color: context.currentTheme.textNeutralPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.localization.empty_cards_list_message,
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
        ),
      ),
    );
  }
}

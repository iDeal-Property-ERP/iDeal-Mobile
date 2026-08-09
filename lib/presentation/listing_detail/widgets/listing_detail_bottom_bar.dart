import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';

class ListingDetailBottomBar extends StatelessWidget {
  const ListingDetailBottomBar({super.key, required this.detail});

  final ListingDetail detail;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.currentTheme.bgSurfaceBase2,
        border: Border(
          top: BorderSide(color: context.currentTheme.strokeNeutralLight100),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatPrice(detail.price, detail.currency),
                    style: AppTextStyles.h5Bold.copyWith(
                      color: context.currentTheme.textNeutralPrimary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    context.localization.listings_per_month,
                    style: AppTextStyles.p3Regular.copyWith(
                      color: context.currentTheme.textNeutralSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: Center(
                        child: AppButton(
                          key: keys.listingDetail.messageButton,
                          style: AppButtonStyle.primary,
                          size: AppButtonSize.large,
                          label: context.localization.listing_detail_message,
                          leftIcon: TablerIcons.message,
                          shouldSetFullWidth: true,
                          borderRadius: 12,
                          foregroundColor:
                              context.currentTheme.textNeutralWhite,
                          backgroundColor: context.currentTheme.bgBrandDefault,
                          onPressed: () {
                            // TODO(listing-detail): wire chat
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CallButton(label: context.localization.listing_detail_call),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: context.currentTheme.bgSurfaceBase2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO(listing-detail): wire chat
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.currentTheme.strokeNeutralLight100,
              ),
            ),
            child: Icon(
              TablerIcons.phone,
              size: 20,
              color: context.currentTheme.textNeutralPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

String _formatPrice(double? price, String currency) {
  if (price == null) return '—';

  final amount = price == price.roundToDouble()
      ? price.toInt().toString()
      : price.toString();

  return currency == 'USD' ? '\$$amount' : '$amount $currency';
}

import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/checkout/widget/order_summary.dart';
import 'package:ideal_mobile/presentation/checkout/widget/shipping_address.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ShippingScreen extends StatelessWidget {
  const ShippingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          context.localization.shipping_address,
          style: AppTextStyles.p2Bold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 16),
        const ShippingAddress(),
        const SizedBox(height: 16),
        const OrderSummary(),
        const SizedBox(height: 16),
      ],
    );
  }
}

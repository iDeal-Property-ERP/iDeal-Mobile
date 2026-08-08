import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/checkout/widget/cart_item_lists.dart';
import 'package:ideal_mobile/presentation/checkout/widget/order_summary.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          context.localization.cart_items,
          style: AppTextStyles.p2Bold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 16),
        const CartItemLists(),
        const SizedBox(height: 16),
        const OrderSummary(),
        const SizedBox(height: 16),
      ],
    );
  }
}

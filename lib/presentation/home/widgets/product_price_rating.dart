import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/home/domain/entities/product.dart';
import 'package:ideal_mobile/utils/currency_formatter_util.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ProductPriceRating extends StatelessWidget {
  final Product product;

  const ProductPriceRating({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Expanded(
          child: Text(
            CurrencyFormatterUtil.format(
              product.price.toString(),
              locale: context.localization.localeName,
            ),
            maxLines: 1,
            style: AppTextStyles.p3SemiBold.copyWith(
              color: context.currentTheme.textBrandPrimary,
            ),
          ),
        ),
        Icon(Icons.star, color: context.currentTheme.bgWarningHover, size: 16),
        const SizedBox(width: 4),
        Text(
          product.rating.toString(),
          style: AppTextStyles.p4Medium.copyWith(
            color: context.currentTheme.textNeutralSecondary,
          ),
        ),
      ],
    );
  }
}

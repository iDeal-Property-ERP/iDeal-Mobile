import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';

class PaymentProcessingTitle extends StatelessWidget {
  const PaymentProcessingTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.localization.processing_your_payment,
      style: AppTextStyles.h1,
      textAlign: .center,
    );
  }
}
